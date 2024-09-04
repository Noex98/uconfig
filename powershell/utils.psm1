function g_co {
    param([switch]$f)

    if ($f) {
        git fetch --prune
    }

    $previewGraph = "git log {} --graph --decorate --oneline --abbrev-commit --color=always -n 100"

    $branch = git branch --all --sort=-committerdate | rg --invert-match '\->' | rg --only-matching '[^ ]+$' | fzf --preview=$previewGraph
    
    if ($branch) {
        if ($branch -match '^remotes/') {
            $localBranchName = $branch -replace '^remotes/origin/', ''
            git checkout -b $localBranchName --track $branch
        } else {
            git checkout $branch
        }
    }
}


function open-file {
    $fileName = rg --files | fzf --preview "bat --color=always {}"
    if ($fileName) {
        code -r $fileName
    }
}

function cd-project {

    $included = @('package.json')
    $excluded = @('**/node_modules/**', '**/Library/**', '**/Temp/**', '**/obj/**', '**/Build/**')

    $rgCommand = 'rg --files'

    foreach ($include in $included) {
        $rgCommand += " --glob '$include'"
    }

    foreach ($exclude in $excluded) {
        $rgCommand += " --glob '!$exclude'"
    }

    $directories = Invoke-Expression $rgCommand | 
                   ForEach-Object { Split-Path $_ -Parent } | 
                   Sort-Object -Unique

    if ($directories.Count -eq 0) {
        Write-Host "No matching directories found"
        return
    }

    $selectedDirectory = $directories | fzf --preview "dir {}"

    if ($selectedDirectory) {
        Set-Location $selectedDirectory
        Clear-Host
    }
}

function utils {
    $currentFunctionName = 'utils'
    $utilsPath = "$PSScriptRoot\utils.psm1"

    $functions = Select-String -Path $utilsPath -Pattern 'function\s+([\w-]+)' | 
                 ForEach-Object {
                     $_.Matches[0].Groups[1].Value
                 } | Where-Object { $_ -ne $currentFunctionName }

    if ($functions.Count -eq 0) {
        Write-Host "No functions found in your profile."
        return
    }

    $selectedFunction = $functions | Sort-Object | fzf 

    if ($selectedFunction) {
        Invoke-Expression $selectedFunction
    }
}

function cd-project {
    param(
        [switch]$g  # Boolean flag for global search
    )

    $included = @('package.json')
    $excluded = @('**/node_modules/**', '**/Library/**', '**/Temp/**', '**/obj/**', '**/Build/**')

    if ($g) {
        $rgCommand = "rg --files $HOME"
    } else {
        $rgCommand = 'rg --files'
    }

    # Add the base directory to the rg command
    $rgCommand += "$baseDirectory"

    foreach ($include in $included) {
        $rgCommand += " --glob '$include'"
    }

    foreach ($exclude in $excluded) {
        $rgCommand += " --glob '!$exclude'"
    }

    # Execute the rg command and process the results
    $directories = Invoke-Expression $rgCommand | 
                   ForEach-Object { Split-Path $_ -Parent } | 
                   Sort-Object -Unique

    if ($directories.Count -eq 0) {
        Write-Host "No matching directories found"
        return
    }

    # Use fzf to select a directory
    $selectedDirectory = $directories | fzf --preview "dir {}"

    # If a directory is selected, change to that directory
    if ($selectedDirectory) {
        Set-Location $selectedDirectory
        Clear-Host
    }
}


function g_diff {
    git diff --name-only | fzf -m --ansi --preview 'git diff --color=always {-1}'
}