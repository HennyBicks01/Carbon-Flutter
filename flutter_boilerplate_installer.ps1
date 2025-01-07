# Flutter Boilerplate Project Installer

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    
    [string]$DestinationPath = "C:\Users\benhi\Downloads\$ProjectName",
    [string]$BoilerplatePath = "C:\Users\benhi\Downloads\carbon\carbon_app"
)

# Ensure destination path doesn't exist
if (Test-Path $DestinationPath) {
    Write-Host "Error: Destination path $DestinationPath already exists." -ForegroundColor Red
    exit 1
}

# Create destination directory
New-Item -Path $DestinationPath -ItemType Directory | Out-Null

# Function to copy directory with exclusions
function Copy-Directory {
    param(
        [string]$Source,
        [string]$Destination,
        [string[]]$Exclude = @('.git', 'build', '.gradle', '.idea')
    )
    
    Get-ChildItem -Path $Source -Recurse | ForEach-Object {
        $relativePath = $_.FullName.Substring($Source.Length + 1)
        $destPath = Join-Path $Destination $relativePath
        
        # Skip excluded directories
        if ($Exclude | Where-Object { $relativePath -like "*$_*" }) {
            return
        }
        
        if ($_.PSIsContainer) {
            # Create directory
            New-Item -Path $destPath -ItemType Directory -Force | Out-Null
        } else {
            # Copy file
            Copy-Item -Path $_.FullName -Destination $destPath -Force
        }
    }
}

# Copy boilerplate files
Copy-Directory -Source $BoilerplatePath -Destination $DestinationPath

# Manually copy Android-specific files that might be excluded
$androidSourcePath = Join-Path $BoilerplatePath "android"
$androidDestPath = Join-Path $DestinationPath "android"

# Ensure these critical Android files are copied
$criticalAndroidFiles = @(
    "gradlew",
    "gradlew.bat",
    "gradle\wrapper\gradle-wrapper.jar",
    "gradle\wrapper\gradle-wrapper.properties",
    "app\build.gradle",
    "build.gradle",
    "settings.gradle"
)

foreach ($file in $criticalAndroidFiles) {
    $sourcePath = Join-Path $androidSourcePath $file
    $destPath = Join-Path $androidDestPath $file
    
    if (Test-Path $sourcePath) {
        $destDir = Split-Path $destPath -Parent
        New-Item -Path $destDir -ItemType Directory -Force | Out-Null
        Copy-Item -Path $sourcePath -Destination $destPath -Force
    }
}

# Function to replace text in files
function Replace-InFile {
    param(
        [string]$FilePath,
        [string]$OldText,
        [string]$NewText
    )
    
    if (Test-Path $FilePath) {
        $content = Get-Content $FilePath -Raw
        $content = $content -replace [regex]::Escape($OldText), $NewText
        $content | Set-Content $FilePath -Encoding UTF8
    }
}

# Update project references
$filesToUpdate = @(
    "$DestinationPath\pubspec.yaml",
    "$DestinationPath\android\app\build.gradle",
    "$DestinationPath\android\app\src\main\AndroidManifest.xml",
    "$DestinationPath\ios\Runner\Info.plist",
    "$DestinationPath\lib\main.dart",
    "$DestinationPath\lib\main_development.dart",
    "$DestinationPath\lib\main_staging.dart"
)

foreach ($file in $filesToUpdate) {
    if (Test-Path $file) {
        Replace-InFile -FilePath $file -OldText "carbon_app" -NewText $ProjectName
        Replace-InFile -FilePath $file -OldText "com.example.carbon_app" -NewText "com.example.$ProjectName"
    }
}

# Update Android Manifest for new embedding
$androidManifestPath = "$DestinationPath\android\app\src\main\AndroidManifest.xml"
if (Test-Path $androidManifestPath) {
    $manifestContent = Get-Content $androidManifestPath -Raw
    
    # Remove old Flutter embedding references
    $manifestContent = $manifestContent -replace '<meta-data\s+android:name="io.flutter.app.FlutterGoogleServicesUseLibrary"\s+android:value="true"\s*/>', ''
    
    # Ensure FlutterActivity is the main activity
    $manifestContent = $manifestContent -replace 'android:name="android.intent.action.MAIN">\s*<intent-filter>', 'android:name="android.intent.action.MAIN">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme"
                />
            <meta-data
                android:name="io.flutter.embedding.android.SplashScreenDrawable"
                android:resource="@drawable/launch_background"
                />'
    
    # Ensure FlutterActivity is used
    $manifestContent = $manifestContent -replace 'android:name="\S+"', 'android:name="io.flutter.embedding.android.FlutterActivity"'
    
    $manifestContent | Set-Content $androidManifestPath -Encoding UTF8
}

# Update Android app build.gradle for new embedding
$androidBuildGradlePath = "$DestinationPath\android\app\build.gradle"
if (Test-Path $androidBuildGradlePath) {
    $buildGradleContent = Get-Content $androidBuildGradlePath -Raw
    
    # Update minimum SDK version
    $buildGradleContent = $buildGradleContent -replace 'minSdkVersion\s+\d+', 'minSdkVersion 21'
    
    # Ensure compileSdkVersion is up to date
    $buildGradleContent = $buildGradleContent -replace 'compileSdkVersion\s+\d+', 'compileSdkVersion 33'
    
    $buildGradleContent | Set-Content $androidBuildGradlePath -Encoding UTF8
}

# Create new README
$readmeContent = @"
# $ProjectName

## Overview
A Flutter project based on the Carbon App Boilerplate.

## Getting Started
1. Clone the repository
2. Run ``flutter pub get``
3. Run the app with ``flutter run``

## Project Structure
- ``lib/``: Main application code
- ``test/``: Unit and widget tests
- ``android/``, ``ios/``: Platform-specific configurations

## Development
- Development build: ``flutter run lib/main_development.dart``
- Staging build: ``flutter run lib/main_staging.dart``
- Production build: ``flutter run lib/main.dart``
"@

$readmeContent | Set-Content "$DestinationPath\README.md"

# Initialize git
Set-Location $DestinationPath
git init | Out-Null
git add . | Out-Null
git commit -m "Initial commit: $ProjectName project" | Out-Null

# Post-creation steps
flutter pub get | Out-Null
flutter clean | Out-Null

Write-Host "Project $ProjectName created successfully in $DestinationPath" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. cd $DestinationPath" -ForegroundColor Cyan
Write-Host "2. flutter pub get" -ForegroundColor Cyan
Write-Host "3. flutter run" -ForegroundColor Cyan
