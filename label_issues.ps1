# Set GITHUB_TOKEN in your environment before running this script
# e.g.: $env:GITHUB_TOKEN = "ghp_..."
$token = $env:GITHUB_TOKEN
$owner = "fsamura01"
$repo = "project-feedback"

# Fetch all issues (open and closed)
$issues = Invoke-RestMethod -Headers @{Authorization = "token $token"; Accept = "application/vnd.github+json"} -Uri "https://api.github.com/repos/$owner/$repo/issues?state=all&per_page=100"

foreach ($issue in $issues) {
    $num = $issue.number
    if ($num -ge 2 -and $num -le 31) {
        $labels = @("AMVP")
    } else {
        $labels = @("post-MVP")
    }
    # Apply labels (replace existing labels)
    Invoke-RestMethod -Method Post -Headers @{Authorization = "token $token"; Accept = "application/vnd.github+json"} -Uri "https://api.github.com/repos/$owner/$repo/issues/$num/labels" -Body (ConvertTo-Json $labels)
}
