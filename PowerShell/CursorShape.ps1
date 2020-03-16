## COPYING ******************************************************************
## For copyright and licensing terms, see the file named LICENSE.
## **************************************************************************

## A test of changing the cursor shape.

## NOTE: This script does not set [console]::OutputEncoding.
## This is one of the test conditions that one might want to vary.

if ($host.PrivateData -and $host.PrivateData.GetType().Name -eq "ISEOptions") {
    Write-Error "Do not run this in PowerShell ISE."
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

function DECSCUSR {
	 param ($p = 1)
    [console]::Write([string]::format("{0}{1} q", $CSI, $p)) 
}

function DECPrivateMode {
    param ($m = 1, $v = $true) 
    $v = if ($v) {"h"} else {"l"}
    [console]::Write([string]::format("{0}?{1:D}{2}", $CSI, $m, $v)) 
}

function DECTCEM {
    param ($v = $true) 
    DECPrivateMode 25 $v
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
    
    CUP 0 0 ; [console]::Write("  < To see the cursor, ensure that this window has the input focus.`r") 
	 DECTCEM $true
	 DECSCUSR $script:s
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

# cursor shape controls

$underline_radiobutton = New-Object System.Windows.Forms.RadioButton
$underline_radiobutton.Text = "underline"
$underline_radiobutton.AutoSize = $true
$underline_radiobutton.Top = 10
$underline_radiobutton.Left = 10
$block_radiobutton = New-Object System.Windows.Forms.RadioButton
$block_radiobutton.Text = "block"
$block_radiobutton.AutoSize = $true
$block_radiobutton.Top = $underline_radiobutton.Top + $vertical_grid
$block_radiobutton.Left = $underline_radiobutton.Left
$bar_radiobutton = New-Object System.Windows.Forms.RadioButton
$bar_radiobutton.Text = "bar"
$bar_radiobutton.AutoSize = $true
$bar_radiobutton.Top = $block_radiobutton.Top + $vertical_grid
$bar_radiobutton.Left = $block_radiobutton.Left
$user_radiobutton = New-Object System.Windows.Forms.RadioButton
$user_radiobutton.Text = "user"
$user_radiobutton.AutoSize = $true
$user_radiobutton.Top = $bar_radiobutton.Top + $vertical_grid
$user_radiobutton.Left = $bar_radiobutton.Left

$shape_groupbox = New-Object System.Windows.Forms.GroupBox
$shape_groupbox.Controls.Add($underline_radiobutton)
$shape_groupbox.Controls.Add($block_radiobutton)
$shape_groupbox.Controls.Add($bar_radiobutton)
$shape_groupbox.Controls.Add($user_radiobutton)
$shape_groupbox.AutoSize = $true
$shape_groupbox.Left = $csi_groupbox.Left
$shape_groupbox.Top = $csi_groupbox.Top + $vertical_grid * 1 + 15
$shape_groupbox.Height = $vertical_grid - 15

$blink_checkbox= New-Object System.Windows.Forms.CheckBox
$blink_checkbox.Text = "blink"
$blink_checkbox.AutoSize = $true
$blink_checkbox.Top = $shape_groupbox.Top + $vertical_grid * 4 + 15
$blink_checkbox.Left = $shape_groupbox.Left

$background_checkbox = New-Object System.Windows.Forms.CheckBox
$background_checkbox.Text = "Light background (inverse video, DEC mode 5)"
$background_checkbox.AutoSize = $true
$background_checkbox.Top = $blink_checkbox.Top + $vertical_grid
$background_checkbox.Left = $blink_checkbox.Left

# main form

$form = New-Object System.Windows.Forms.Form
$form.Controls.Add($csi_label)
$form.Controls.Add($csi_groupbox)
$form.Controls.Add($shape_groupbox)
$form.Controls.Add($blink_checkbox)
$form.Controls.Add($background_checkbox)
$form.Text = "DECSCUSR test"
$form.AutoSize = $true
$form.Opacity = 0.9

# events

function Click {
   $script:CSI = C1 155
	if ($script:blink_checkbox.Checked) {
		$script:s = if ($script:bar_radiobutton.Checked) {5} elseif ($script:underline_radiobutton.Checked) {3} elseif ($script:block_radiobutton.Checked) {1} else {0}
	} else {
		$script:s = if ($script:bar_radiobutton.Checked) {6} elseif ($script:underline_radiobutton.Checked) {4} elseif ($script:block_radiobutton.Checked) {2} else {0}
	}
	$script:scnm = $script:background_checkbox.Checked
   Do-It
}

if ([Console]::OutputEncoding.IsSingleByte) {
    $csi7_radiobutton.Checked = $true
} else {
    $csi8_radiobutton.Checked = $true
}
$underline_radiobutton.Checked = $true
$blink_checkbox.Checked = $true
$background_checkbox.Checked = $true

$csi7_radiobutton.add_Click({Click})
$csi8_radiobutton.add_Click({Click})
$csiu_radiobutton.add_Click({Click})
$underline_radiobutton.add_Click({Click})
$block_radiobutton.add_Click({Click})
$bar_radiobutton.add_Click({Click})
$user_radiobutton.add_Click({Click})
$blink_checkbox.add_Click({Click})
$background_checkbox.add_Click({Click})

Click

$r = $form.ShowDialog()