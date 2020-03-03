## COPYING ******************************************************************
## For copyright and licensing terms, see the file named LICENSE.
## **************************************************************************

## A test to see whether pending line wrap is properly implemented
## This is easy to get wrong, not least because it is almost wholly undocumented.

## NOTE: This script does not set [console]::OutputEncoding.
## This is one of the test conditions that one might want to vary.

if ($host.PrivateData -and $host.PrivateData.GetType().Name -eq "ISEOptions") {
    Write-Error "Do not run this in PowerShell ISE."
    return
}
if ($host.UI.RawUI.WindowBuffer.Height -lt 1) {
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

function EL {
    param ($p = 2) 
    [console]::Write([string]::format("{0}{1:D}K", $CSI, $p)) 
}

function SGR {
    [console]::Write([string]::format("{0}{1}m", $CSI, $(ECMA48Params $args))) 
}

function CUU { 
    param ($p = 1) 
    [console]::Write([string]::format("{0}{1:D}A", $CSI, $p)) 
}

function CUD { 
    param ($p = 1) 
    [console]::Write([string]::format("{0}{1:D}B", $CSI, $p)) 
}

function CUF { 
    param ($p = 1) 
    [console]::Write([string]::format("{0}{1:D}C", $CSI, $p)) 
}

function CUB { 
    param ($p = 1) 
    [console]::Write([string]::format("{0}{1:D}D", $CSI, $p)) 
}

function DECPrivateMode {
    param ($m = 1, $v = $true) 
    $v = if ($v) {"h"} else {"l"}
    [console]::Write([string]::format("{0}?{1:D}{2}", $CSI, $m, $v)) 
}

function DECOM {
    param ($v = $true) 
    DECPrivateMode 6 $v
}

function DECLRMM {
    param ($v = $true) 
    DECPrivateMode 69 $v
}

function DECSTBM { 
    [console]::Write([string]::format("{0}{1}r", $CSI, $(ECMA48Params $args))) 
}

function DECSLRM { 
    [console]::Write([string]::format("{0}{1}s", $CSI, $(ECMA48Params $args))) 
}

function Do-It {
    $columns = $Host.UI.RawUI.WindowSize.Width
    $rows = $Host.UI.RawUI.WindowSize.Height
    DECOM $false
    DECSTBM 1 $rows
    DECLRMM $true
    DECSLRM 1 $columns
    DECLRMM $false
    CUP
    SGR 27
    ED 2
    if ($origin_mode) {
        CUP
        SGR 7
        ED 2
        DECOM $true
        DECSTBM $($columns / 4) $($rows * 3 / 4)
        DECLRMM $true
        DECSLRM $($columns / 4) $($columns * 3 / 4)
        DECLRMM $false
        $rows /= 2
        $columns /= 2
    }
    
    for ($r = 1; $r -le $rows; ++$r) {
        if ($r -eq 1) { 
            CUP $r 1 ; [console]::Write("L") ; EL 3
        } else { 
            CUP $r 1 ; [console]::Write("!") ; EL 3
        }
    }
    CUP  4 10 ; [console]::Write("A RL on the right and a ! on the left")
    CUP  5 10 ; [console]::Write("indicate that during pending wrap the")
    CUP  6 10 ; [console]::Write("cursor does not behave as if it is in")
    CUP  7 10 ; [console]::Write("the right place.")
    for ($r = 1; $r -le $rows; ++$r) {
        if ($r -eq $rows) {
            CUP $r $columns ; [console]::Write("R")
        } else {
            CUP $r $columns
            # Correct: Prints ! in last column, overwriten by R.
            # Faulty: Prints ! in last column, preceded by R in penultimate column.
            [console]::Write("!`bR")
            # Correct: Wraps and prints L in first column.
            # Faulty: Prints L in last column.
            [console]::Write("L")
        }
    }

    if ($origin_mode) {
        SGR 27
    }
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

$origin_mode_checkbox = New-Object System.Windows.Forms.CheckBox
$origin_mode_checkbox.Text = "Use DEC origin mode and margins"
$origin_mode_checkbox.AutoSize = $true
$origin_mode_checkbox.Top = $csi_label.Top + $vertical_grid
$origin_mode_checkbox.Left = $csi_label.Left

# main form

$form = New-Object System.Windows.Forms.Form
$form.Controls.Add($csi_label)
$form.Controls.Add($csi_groupbox)
$form.Controls.Add($origin_mode_checkbox)
$form.Text = "Pending Wrap test"
$form.AutoSize = $true
$form.Opacity = 0.9

# events

function Click {
    $script:CSI = C1 155
    $script:origin_mode = $origin_mode_checkbox.Checked
    Do-It
}

if ([Console]::OutputEncoding.IsSingleByte) {
    $csi7_radiobutton.Checked = $true
} else {
    $csi8_radiobutton.Checked = $true
}
$scnm = $false

$csi7_radiobutton.add_Click({Click})
$csi8_radiobutton.add_Click({Click})
$csiu_radiobutton.add_Click({Click})
$origin_mode_checkbox.add_Click({Click})

Click

$r = $form.ShowDialog()