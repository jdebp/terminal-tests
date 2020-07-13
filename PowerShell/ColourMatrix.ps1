## COPYING ******************************************************************
## For copyright and licensing terms, see the file named LICENSE.
## **************************************************************************

## A 16 by 16 colour matrix.

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

function LF {
    [console]::Write("`n") 
}

function Set-16Colour {
    param ($isbg, $index)
    if ($index -ne $null) {
        switch ($colourmode) {
            "A" {
                if ($index -ge 8) { $index = $index + 90 - 30 - 8 }
                $index = $index + 30
                if ($isbg) { $index = $index + 10 }
                [console]::Write([string]::format("{0}{1:D}m", $CSI, $index))
            }
            "V" {
                $sgr = if ($isbg) {48} else {38}
                $pn = if ($script:conformant) { ECMA48SubParams $sgr, 5, $index } else { ECMA48Params $sgr, 5, $index }
                [console]::Write([string]::format("{0}{1}m", $CSI, $pn))
            }
            "T" {
                $sgr = if ($isbg) {48} else {38}
                if ($index -eq 8) {
                    $r = 64
                    $g = 64
                    $b = 64
                } else {
                    $v = if ($index -band 8) { 255 } else { 160 }
                    $r = (($index -band 1) / 1) * $v
                    $g = (($index -band 2) / 2) * $v
                    $b = (($index -band 4) / 4) * $v
                }
                $pn = if ($script:conformant) { ECMA48SubParams $sgr, 2, $null, $r, $g, $b } else { ECMA48Params $sgr, 2, $r, $g, $b }
                [console]::Write([string]::format("{0}{1}m", $CSI, $pn))
            }
        }
    } else {
        $sgr = if ($isbg) {49} else {39}
        [console]::Write([string]::format("{0}{1:D}m", $CSI, $sgr))
    }
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
    Set-16Colour 0
    Set-16Colour 1
    DECSCNM $($script:scnm -gt 0)
    ED 2
    [console]::Write("Colour matrix`n")
    for ($fg = 0; $fg -lt 16; ++$fg) {
        for ($bg = 0; $bg -lt 16; ++$bg) {
            Set-16Colour 0 $fg
            Set-16Colour 1 $bg
            [console]::Write(" ## ")
        }
        Set-16Colour 0
        Set-16Colour 1
        LF
    }
    LF

    [console]::Write("Greyscale`n")
    for ($bg = 0; $bg -lt 24; ++$bg) {
        $fg = 24 - $bg
        Set-Greyscale 0 $fg
        Set-Greyscale 1 $bg
        [console]::Write(" - ")
    }
    Set-16Colour 0
    Set-16Colour 1
    LF
}

Add-Type -AssemblyName System.Windows.Forms

$vertical_grid = 30

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
$csi_groupbox.Left = $colourmode_groupbox.Left
$csi_groupbox.Top = $csi_label.Top - 5
$csi_groupbox.Height = $vertical_grid - 15

# Checkboxes

$strict_checkbox = New-Object System.Windows.Forms.CheckBox
$strict_checkbox.Text = "Standards conformant (ITU T.416 / ISO IEC 8613-6:1994 section 13.1.8)"
$strict_checkbox.AutoSize = $true
$strict_checkbox.Top = $csi_label.Top + $vertical_grid +10
$strict_checkbox.Left = $csi_label.Left

$background_checkbox = New-Object System.Windows.Forms.CheckBox
$background_checkbox.Text = "Light background (inverse video, DEC mode 5)"
$background_checkbox.AutoSize = $true
$background_checkbox.Top = $strict_checkbox.Top + $vertical_grid
$background_checkbox.Left = $csi_label.Left

# main form

$form = New-Object System.Windows.Forms.Form
$form.Controls.Add($colourmode_label)
$form.Controls.Add($colourmode_groupbox)
$form.Controls.Add($csi_label)
$form.Controls.Add($csi_groupbox)
$form.Controls.Add($strict_checkbox)
$form.Controls.Add($background_checkbox)
$form.Text = "Colour matrix test"
$form.AutoSize = $true
$form.Opacity = 0.9

# timer and events

function Click {
    $script:colourmode = if ($Script:aixterm_radiobutton.Checked) { "A" } elseif ($Script:xterm_radiobutton.Checked) { "V" } else { "T" }
    C1
    $script:conformant = $script:strict_checkbox.Checked
    $script:scnm = $script:background_checkbox.Checked
    Do-It
}

if ([Console]::OutputEncoding.IsSingleByte) {
    $csi7_radiobutton.Checked = $true
} else {
    $csi8_radiobutton.Checked = $true
}
$aixterm_radiobutton.Checked = $true
$strict_checkbox.Checked = $true
$background_checkbox.Checked = $true

$aixterm_radiobutton.add_Click({Click})
$xterm_radiobutton.add_Click({Click})
$truecolour_radiobutton.add_Click({Click})
$csi7_radiobutton.add_Click({Click})
$csi8_radiobutton.add_Click({Click})
$csiu_radiobutton.add_Click({Click})
$strict_checkbox.add_Click({Click})
$background_checkbox.add_Click({Click})

Click

$r = $form.ShowDialog()