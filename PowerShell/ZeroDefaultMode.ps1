## COPYING ******************************************************************
## For copyright and licensing terms, see the file named LICENSE.
## **************************************************************************

## A test of zero no longer being the same as an empty (i.e. default) parameter
## See Annex E of ECMA-48:1986 .

if ($host.PrivateData -and $host.PrivateData.GetType().Name -eq "ISEOptions") {
    Write-Error "Do not run this in PowerShell ISE."
    return
}

function C1 {
    if ($script:csi7_radiobutton.Checked) {
        $script:CSI = [char]27 + [char]0x5B
        [Console]::OutputEncoding = [System.Text.Encoding]::ASCII
    } else { 
        $script:CSI = [char]0x9B
        if ($script:csi8_radiobutton.Checked) {
            [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        } else {
            [Console]::OutputEncoding = [System.Text.Encoding]::Unicode
		}
    }
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

function Mode {
    param ($m = 1, $v = $true) 
    $v = if ($v) {"h"} else {"l"}
    [console]::Write([string]::format("{0}{1:D}{2}", $CSI, $m, $v)) 
}

function ZDM {
    param ($v = $true) 
    Mode 22 $v
}

function Do-It {
    CUP
    SGR
    ED 2
    
    CUP 16 0 ; [console]::Write("Since 1986, a 0 parameter in a control sequence has meant zero;")
    CUP 17 0 ; [console]::Write("a movement of length zero in the case of cursor positionining.")
    CUP  4 0 ; [console]::Write("These three should be identical and correct.")

    # Outer markers
    CUP 8 20 ; [console]::Write("N") 
    CUP 9 20 ; [console]::Write("|") 
    CUP 10 18 ; [console]::Write("W-+-E") 
    CUP 11 20 ; [console]::Write("|") 
    CUP 12 20 ; [console]::Write("S") 
    CUP 8 10 ; [console]::Write("N") 
    CUP 9 10 ; [console]::Write("|") 
    CUP 10 8 ; [console]::Write("W-+-E") 
    CUP 11 10 ; [console]::Write("|") 
    CUP 12 10 ; [console]::Write("S") 
    CUP 10 30 ; [console]::Write("N") 
    CUP 9 30 ; [console]::Write("|") 
    CUP 10 28 ; [console]::Write("W-+-E") 
    CUP 11 30 ; [console]::Write("|") 
    CUP 12 30 ; [console]::Write("S") 

    # Test output that should not overwrite the markers
    CUP 10 10
    CUU 0 ; [console]::Write("N`b") ; CUD 0
    CUD 0 ; [console]::Write("S`b") ; CUU 0
    CUB 0 ; [console]::Write("W`b") ; CUF 0
    CUF 0 ; [console]::Write("E`b") ; CUB 0
    [console]::Write("+")
    CUP 10 30
    CUU 0 ; CUU 0 ;[console]::Write("S`b") ; CUD 0 ; CUD 0
    CUD 0 ; CUD 0 ;[console]::Write("N`b") ; CUU 0 ; CUU 0
    CUB 0 ; CUB 0 ;[console]::Write("E`b") ; CUF 0 ; CUF 0
    CUF 0 ; CUF 0 ;[console]::Write("W`b") ; CUB 0 ; CUB 0
    [console]::Write("+")
    
    CUP 21 0
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
$csi8_radiobutton.Text = "UTF-8"
$csi8_radiobutton.AutoSize = $true
$csi8_radiobutton.Top = $csi7_radiobutton.Top
$csi8_radiobutton.Left = $csi7_radiobutton.Left + 60
$csiu_radiobutton = New-Object System.Windows.Forms.RadioButton
$csiu_radiobutton.Text = "UTF-16"
$csiu_radiobutton.AutoSize = $true
$csiu_radiobutton.Top = $csi8_radiobutton.Top
$csiu_radiobutton.Left = $csi8_radiobutton.Left + 60

$csi_groupbox = New-Object System.Windows.Forms.GroupBox
$csi_groupbox.Controls.Add($csi7_radiobutton)
$csi_groupbox.Controls.Add($csi8_radiobutton)
$csi_groupbox.Controls.Add($csiu_radiobutton)
$csi_groupbox.AutoSize = $true
$csi_groupbox.Left = $csi_label.Left + 100
$csi_groupbox.Top = $csi_label.Top - 5
$csi_groupbox.Height = $vertical_grid - 15

# checkboxes

$zdm_checkbox = New-Object System.Windows.Forms.CheckBox
$zdm_checkbox.Text = "Mode 22"
$zdm_checkbox.AutoSize = $true
$zdm_checkbox.Top = $csi_label.Top + $vertical_grid
$zdm_checkbox.Left = $csi_label.Left

# main form

$form = New-Object System.Windows.Forms.Form
$form.Controls.Add($csi_label)
$form.Controls.Add($csi_groupbox)
$form.Controls.Add($zdm_checkbox)
$form.Text = "Zero Default Mode test"
$form.AutoSize = $true
$form.Opacity = 0.9

# events

function Click {
    C1
    ZDM $zdm_checkbox.Checked
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
$zdm_checkbox.add_Click({Click})

Click

$r = $form.ShowDialog()