## COPYING ******************************************************************
## For copyright and licensing terms, see the file named LICENSE.
## **************************************************************************

## A test of setting and clearing tabs
## Several tab rulers are displayed.

## NOTE: This script does not set [console]::OutputEncoding.
## This is one of the test conditions that one might want to vary.

if ($host.PrivateData -and $host.PrivateData.GetType().Name -eq "ISEOptions") {
    Write-Error "Do not run this in PowerShell ISE."
    return
}
if ($host.UI.RawUI.WindowSize.Width -lt 1) {
	Write-Error "This requires a valid window buffer."
   return
}

function C1 {
    param ($n)
    if ($Script:csi7_radiobutton.Checked) { [char]27 + [char]($n - 64) } elseif ($Script:csi8_radiobutton.Checked) { [char]$n } else { [char]194 + [char]$n }
}

function ECMA48Params {
    $a = @()
    foreach ($arg in $args) { $a += $arg }
    [String]::Join(";",$a)
}

function ECMA48SubParams {
    $a = @()
    foreach ($arg in $args) { $a += $arg }
    [String]::Join(":",$a)
}

function CUP { 
    [console]::Write([string]::format("{0}{1}H", $CSI, $(ECMA48Params $args))) 
}

function ED {
    param ($p = 2) 
    [console]::Write([string]::format("{0}{1:D}J", $CSI, $p)) 
}

function SGR {
    [console]::Write([string]::format("{0}{1}m", $CSI, $(ECMA48Params $args))) 
}

function TBC {
    [console]::Write([string]::format("{0}{1}g", $CSI, $(ECMA48Params $args))) 
}

function CR {
    [console]::Write("`r") 
}

function LF {
    [console]::Write("`n") 
}

function CTC {
    [console]::Write([string]::format("{0}{1}W", $CSI, $(ECMA48Params $args))) 
}

function DECCTC {
    [console]::Write([string]::format("{0}?{1}W", $CSI, $(ECMA48Params $args))) 
}

function Show-Tabs {
    $columns = $Host.UI.RawUI.BufferSize.Width
    CR 
    SGR 7
    for ($column = 1; $column -le $columns; ++$column) {
        $d = $column % 10
        if (5 -eq $d) {
            [console]::Write("+")
        } elseif (0 -ne $d) {
            [console]::Write("-")
        } else {
            [console]::Write([string]::format("{0:D}",($column / 10) % 10))
        }
    }
    SGR 27
    CR
    LF
    for ($column = 1; $column -le $columns + 1; ++$column) {
        [console]::Write("`tT`b")
    }
    # With pending linewrap correctly implemented:
    CR
    LF
}

function Set-Tabs {
    param ($n, $max)
    if (-not $script:hasctc) { TBC 3 }
    $columns = $Host.UI.RawUI.BufferSize.Width
    for ($column = 1; $column -le $columns; ++$column) {
        if ($max -and $column -gt $max) {
            ;
        } elseif (0 -eq $column % $n) {
            if ($script:hasctc) { CTC 2 } else { [console]::Write($HTS) }
        } else {
            if ($script:hasctc) { CTC 0 }
        }
        [console]::Write(" ")
    }
    CR 
}

function Clear-Tabs {
    if ($script:hasctc) { CTC 5 } else { TBC 3 }
}

function DECPrivateMode {
    param ($m = 1, $v = $true) 
    $v = if ($v) {"h"} else {"l"}
    [console]::Write([string]::format("{0}?{1:D}{2}", $CSI, $m, $v)) 
}

function DECSCNM {
    param ($v = $true) 
    DECPrivateMode 5 $v
}

function Do-It {
    CUP
    SGR
    DECSCNM $($script:scnm -gt 0)
    ED 2

    [console]::Write("No tabstops`n")
    Clear-Tabs
    Show-Tabs

    [console]::Write("Tabs every 8 columns (using DECCTC 5)`n")
    DECCTC 5
    Show-Tabs
    
    [console]::Write("Tabs every column`n")
    Set-Tabs 1
    Show-Tabs

    [console]::Write("Tabs every 3 columns up to a maximum of 21`n")
    Set-Tabs 3 21
    Show-Tabs

    [console]::Write("Tabs every 7 columns up to a maximum of 63`n")
    Set-Tabs 7 63
    Show-Tabs

    [console]::Write("Tabs every 8 columns`n")
    Set-Tabs 8
    Show-Tabs

    [console]::Write("Tabs every 9 columns`n")
    Set-Tabs 9
    Show-Tabs

    [console]::Write("Tabs every 11 columns`n")
    Set-Tabs 11
    Show-Tabs
}

Add-Type -AssemblyName System.Windows.Forms

$vertical_grid = 40

# CSI groupbox: 3 radio buttons

$csi_label = New-Object System.Windows.Forms.Label
$csi_label.Text = "C1 characters:"
$csi_label.AutoSize = $true
$csi_label.Left = 10
$csi_label.Top = 10

$csi7_radiobutton = New-Object System.Windows.Forms.RadioButton
$csi7_radiobutton.Text = "7-bit"
$csi7_radiobutton.AutoSize = $true
$csi7_radiobutton.Top = 10
$csi7_radiobutton.Left = 10
$csi8_radiobutton = New-Object System.Windows.Forms.RadioButton
$csi8_radiobutton.Text = "8-bit"
$csi8_radiobutton.AutoSize = $true
$csi8_radiobutton.Top = $csi7_radiobutton.Top
$csi8_radiobutton.Left = $csi7_radiobutton.Left + 50
$csiu_radiobutton = New-Object System.Windows.Forms.RadioButton
$csiu_radiobutton.Text = "Unicode"
$csiu_radiobutton.AutoSize = $true
$csiu_radiobutton.Top = $csi8_radiobutton.Top
$csiu_radiobutton.Left = $csi8_radiobutton.Left + 50

$csi_groupbox = New-Object System.Windows.Forms.GroupBox
$csi_groupbox.Controls.Add($csi7_radiobutton)
$csi_groupbox.Controls.Add($csi8_radiobutton)
$csi_groupbox.Controls.Add($csiu_radiobutton)
$csi_groupbox.AutoSize = $true
$csi_groupbox.Left = $csi_label.Left + 100
$csi_groupbox.Top = $csi_label.Top - 5
$csi_groupbox.Height = $vertical_grid - 15

# checkboxes

$use_ctc_checkbox = New-Object System.Windows.Forms.CheckBox
$use_ctc_checkbox.Text = "Use Cursor Tabulation Control"
$use_ctc_checkbox.AutoSize = $true
$use_ctc_checkbox.Top = $csi_label.Top + $vertical_grid
$use_ctc_checkbox.Left = $csi_label.Left

$background_checkbox = New-Object System.Windows.Forms.CheckBox
$background_checkbox.Text = "Light background (inverse video, DEC mode 5)"
$background_checkbox.AutoSize = $true
$background_checkbox.Top = $use_ctc_checkbox.Top + $vertical_grid
$background_checkbox.Left = $csi_label.Left

# main form

$form = New-Object System.Windows.Forms.Form
$form.Controls.Add($csi_label)
$form.Controls.Add($csi_groupbox)
$form.Controls.Add($use_ctc_checkbox)
$form.Controls.Add($background_checkbox)
$form.Text = "Tabstops test"
$form.AutoSize = $true
$form.Opacity = 0.9

# events

function Click {
    $script:CSI = C1 155
    $script:HTS = C1 136
    $script:hasctc = $script:use_ctc_checkbox.Checked
    $script:scnm = $script:background_checkbox.Checked
    Do-It
}

$csi7_radiobutton.add_Click({Click})
$csi8_radiobutton.add_Click({Click})
$csiu_radiobutton.add_Click({Click})
$use_ctc_checkbox.add_Click({Click})
$background_checkbox.add_Click({Click})

if ([Console]::OutputEncoding.IsSingleByte) {
    $csi7_radiobutton.Checked = $true
} else {
    $csi8_radiobutton.Checked = $true
}
$hasctc = $script:use_ctc_checkbox.Checked

Tick

$r = $form.ShowDialog()