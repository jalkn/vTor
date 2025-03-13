# Define colors for output
$GREEN = "Green"
$RED = "Red"

# Define the root directory (current directory)
$rootDir = "."

# Define the directory names
$directories = @(
    "scripts"
)

# Loop through the directory names
foreach ($dir in $directories) {
    $fullPath = Join-Path -Path $rootDir -ChildPath $dir

    # Check if the directory exists
    if (Test-Path -Path $fullPath -PathType Container) {
        try {
            # Get all items (files and subdirectories) in the directory
            $items = Get-ChildItem -Path $fullPath -Force

            # Loop through each item and delete it
            foreach ($item in $items) {
                try {
                    # Use Remove-Item with -Recurse for subdirectories and -Force to suppress confirmations
                    Remove-Item -Path $item.FullName -Recurse -Force
                    Write-Host "Deleted item: $($item.FullName)" -ForegroundColor $RED
                }
                catch {
                    Write-Host "Error deleting item $($item.FullName): $($_.Exception.Message)" -ForegroundColor $RED
                }
            }

            Write-Host "Deleted all items in: $fullPath" -ForegroundColor $GREEN
        }
        catch {
            # Corrected the exception handling here:
            Write-Host "Error processing directory ${fullPath}: $($_.Exception.Message)"
        }
    }
    else {
        Write-Host "Directory does not exist: $fullPath" -ForegroundColor $RED
    }
}

Write-Host "File and directory deletion complete." -ForegroundColor $GREEN