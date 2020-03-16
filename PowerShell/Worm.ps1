## COPYING ******************************************************************
## For copyright and licensing terms, see the file named LICENSE.
## **************************************************************************

## A test that displays a wriggling worm

## NOTE: This script does not set [console]::OutputEncoding.
## This is one of the test conditions that one might want to vary.

if ($host.PrivateData -and $host.PrivateData.GetType().Name -eq "ISEOptions") {
    Write-Error "Do not run this in PowerShell ISE."
    return
}
if ($host.UI.RawUI.WindowSize.Height -lt 1) {
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

function DECSCNM {
    param ($v = $true) 
    DECPrivateMode 5 $v
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

function Set-Greyscale {
    param ($isbg, $index)
    if ($index) {
        switch ($colourmode) {
            "A" {
                if ($index -lt 6) { 
                    $index = 0
                } elseif ($index -lt 12) {
                    $index = 90 - 30
                } elseif ($index -lt 18) {
                    $index = 7
                } else {
                    $index = 90 - 30 + 7
                }
                $index = $index + 30
                if ($isbg) { $index = $index + 10 }
                [console]::Write([string]::format("{0}{1:D}m", $CSI, $index))
            }
            "V" {
                $sgr = if ($isbg) {48} else {38}
                $pn = if ($script:conformant) { ECMA48SubParams $sgr, 5, $($index + 232) } else { ECMA48Params $sgr, 5, $($index + 232) }
                [console]::Write([string]::format("{0}{1}m", $CSI, $pn))
            }
            "T" {
                $index = 8 + $index * 10
                $sgr = if ($isbg) {48} else {38}
                $pn = if ($script:conformant) { ECMA48SubParams $sgr, 2, $null, $index, $index, $index } else { ECMA48Params $sgr, 2, $index, $index, $index }
                [console]::Write([string]::format("{0}{1}m", $CSI, $pn))
            }
        }
    } else {
        $sgr = if ($isbg) {49} else {39}
        [console]::Write([string]::format("{0}{1:D}m", $CSI, $sgr))
    }
}

function Worm {
	 CUP $worm_head_y $worm_head_x
	 $a = $worm.ToCharArray()
	 for ($g = 0; $g -lt 24; ++$g) {
		 Set-Greyscale 0 $g
		 Set-Greyscale 1 $(23 - $g)
		 if ($g) { [console]::Write("8`b") } else { [console]::Write("O`b") }
		 switch ($a[$g]) {
			 "Z" { }
			 "U" { CUU 1 }
			 "D" { CUD 1 }
			 "F" { CUF 1 }
			 "B" { CUB 1 }
		 }
	 }
	 [console]::Write(" `b")
	 CUP $worm_head_y $worm_head_x
}

function Wriggle {
	 $columns = $Host.UI.RawUI.WindowSize.Width
    $rows = $Host.UI.RawUI.WindowSize.Height
    if ($origin_mode) {
        $rows /= 2
        $columns /= 2
    }
	 $w = $worm.Substring(0,1)
	 if ($w -eq "Z") {
	    $w = "U","D","F","B" | Get-Random
	 } else {
		 $w = ($w,$w) * ($columns - 1) + "U","D","F","B" | Get-Random
	 }
	 switch ($w) {
		 "D" {
			 if ($worm_head_y -gt 1) {
				 --$script:worm_head_y
			 } else {
				 $w = "Z"
			 }
		 }
		 "U" {
			 if ($worm_head_y -lt $rows) {
				 ++$script:worm_head_y
			 } else {
				 $w ="Z"
			 }
		 }
		 "F" {
			 if ($worm_head_x -gt 1) {
				 --$script:worm_head_x
			 } else {
				 $w ="Z"
			 }
		 }
		 "B" {
			 if ($worm_head_x -lt $columns) {
				 ++$script:worm_head_x
			 } else {
				 $w ="Z"
			 }
		 }
	 }
	 $script:worm = $w + $script:worm.substring(0, $script:worm.Length - 1)
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
	 SGR
    ED 2
	 DECSCNM $($script:scnm -gt 0)
    if ($script:origin_mode) {
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
		  SGR
    }
    
    Worm
}

Add-Type -AssemblyName System.Windows.Forms

$vertical_grid = 40

# Colour mode groupbox: 3 radio buttons

$colourmode_label = New-Object System.Windows.Forms.Label
$colourmode_label.Text = "Colour mode:"
$colourmode_label.AutoSize = $true
$colourmode_label.Left = 10
$colourmode_label.Top = 10

$aixterm_radiobutton = New-Object System.Windows.Forms.RadioButton
$aixterm_radiobutton.Text = "AIXTerm 16 colours (supserset of ECMA-48 8 colours)"
$aixterm_radiobutton.AutoSize = $true
$aixterm_radiobutton.Top = 10
$aixterm_radiobutton.Left = 10
$xterm_radiobutton = New-Object System.Windows.Forms.RadioButton
$xterm_radiobutton.Text = "Indirect 256-colour palette"
$xterm_radiobutton.AutoSize = $true
$xterm_radiobutton.Top = $aixterm_radiobutton.Top + $vertical_grid
$xterm_radiobutton.Left = $aixterm_radiobutton.Left
$truecolour_radiobutton = New-Object System.Windows.Forms.RadioButton
$truecolour_radiobutton.Text = "Direct RGB 24-bit (TrueColour)"
$truecolour_radiobutton.AutoSize = $true
$truecolour_radiobutton.Top = $xterm_radiobutton.Top + $vertical_grid
$truecolour_radiobutton.Left = $xterm_radiobutton.Left

$colourmode_groupbox = New-Object System.Windows.Forms.GroupBox
$colourmode_groupbox.Controls.Add($aixterm_radiobutton)
$colourmode_groupbox.Controls.Add($xterm_radiobutton)
$colourmode_groupbox.Controls.Add($truecolour_radiobutton)
$colourmode_groupbox.AutoSize = $true
$colourmode_groupbox.Left = $colourmode_label.Left + 100
$colourmode_groupbox.Top = $colourmode_label.Top - 5
$colourmode_groupbox.Height = $vertical_grid * 3

# CSI groupbox: 3 radio buttons

$csi_label = New-Object System.Windows.Forms.Label
$csi_label.Text = "C1 characters:"
$csi_label.AutoSize = $true
$csi_label.Left = $colourmode_label.Left
$csi_label.Top = $colourmode_label.Top + $vertical_grid * 3 + 15

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

$strict_checkbox = New-Object System.Windows.Forms.CheckBox
$strict_checkbox.Text = "Standards conformant (ITU T.416 / ISO IEC 8613-6:1994 section 13.1.8)"
$strict_checkbox.AutoSize = $true
$strict_checkbox.Top = $csi_label.Top + $vertical_grid + 10
$strict_checkbox.Left = $csi_label.Left

$background_checkbox = New-Object System.Windows.Forms.CheckBox
$background_checkbox.Text = "Light background (inverse video, DEC mode 5)"
$background_checkbox.AutoSize = $true
$background_checkbox.Top = $strict_checkbox.Top + $vertical_grid
$background_checkbox.Left = $csi_label.Left

$origin_mode_checkbox = New-Object System.Windows.Forms.CheckBox
$origin_mode_checkbox.Text = "Use DEC origin mode and margins"
$origin_mode_checkbox.AutoSize = $true
$origin_mode_checkbox.Top = $background_checkbox.Top + $vertical_grid
$origin_mode_checkbox.Left = $csi_label.Left

# main form

$form = New-Object System.Windows.Forms.Form
$form.Controls.Add($colourmode_label)
$form.Controls.Add($colourmode_groupbox)
$form.Controls.Add($csi_label)
$form.Controls.Add($csi_groupbox)
$form.Controls.Add($strict_checkbox)
$form.Controls.Add($background_checkbox)
$form.Controls.Add($origin_mode_checkbox)
$form.Text = "Worm"
$form.AutoSize = $true
$form.Opacity = 0.9

# events

function Click {
    $script:CSI = C1 155
    $script:origin_mode = $origin_mode_checkbox.Checked
	 $script:colourmode = if ($Script:aixterm_radiobutton.Checked) { "A" } elseif ($Script:xterm_radiobutton.Checked) { "V" } else { "T" }
    $script:conformant = $script:strict_checkbox.Checked
    $script:scnm = $script:background_checkbox.Checked
    Do-It
}

function Tick {
    Wriggle
    Worm
}

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 250
$timer.add_tick({Tick})

if ([Console]::OutputEncoding.IsSingleByte) {
   $csi7_radiobutton.Checked = $true
} else {
   $csi8_radiobutton.Checked = $true
}
$aixterm_radiobutton.Checked = $true
$strict_checkbox.Checked = $true
$background_checkbox.Checked = $false

$aixterm_radiobutton.add_Click({Click})
$xterm_radiobutton.add_Click({Click})
$truecolour_radiobutton.add_Click({Click})
$csi7_radiobutton.add_Click({Click})
$csi8_radiobutton.add_Click({Click})
$csiu_radiobutton.add_Click({Click})
$strict_checkbox.add_Click({Click})
$background_checkbox.add_Click({Click})
$origin_mode_checkbox.add_Click({Click})

$worm="DDDDDDFFFFFFFUUBBBBZZBBD"
$worm_head_x = 7
$worm_head_y = 7
$scnm = $true

Click

$timer.Enabled = $true
$r = $form.ShowDialog()
$timer.Enabled = $false