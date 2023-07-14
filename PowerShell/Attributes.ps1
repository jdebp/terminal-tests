## COPYING ******************************************************************
## For copyright and licensing terms, see the file named LICENSE.
## **************************************************************************

## A test of SGR character attributes and ISO colours
## This includes the KiTTY extensions to SGR 4.

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

function DECPrivateMode {
    param ($m = 1, $v = $true)
    $v = if ($v) {"h"} else {"l"}
    [console]::Write([string]::format("{0}?{1:D}{2}", $CSI, $m, $v))
}

function DECSCNM {
    param ($v = $true)
    DECPrivateMode 5 $v
}

function pseudoSGR0 {
    SGR 0
    if($script:colour_all) {
        SGR $script:fg_colour $script:bg_colour
    }
}

function Do-It {
    CUP
    SGR
	DECSCNM $($script:scnm -gt 0)

    pseudoSGR0
    ED 2

    CUP  1 0 ; [console]::Write("Font weights and slants:")
        CUP  2 4 ;
            SGR  1 ; [console]::Write("Upright boldface") ;
            SGR  2 ; [console]::Write(" - demibold (faint boldface)") ;
            SGR 22 ; [console]::Write(" - not boldface nor demibold") ;
            pseudoSGR0
        CUP  3 4 ;
            SGR  0 ; pseudoSGR0 ; [console]::Write("Upright medium (normal)")
            SGR  2 ; [console]::Write(" - light (faint normal)") ;
            SGR 22 ; [console]::Write(" - not light") ;
            pseudoSGR0
        CUP  4 4 ;
            SGR  1 3 ; [console]::Write("Italic boldface") ;
            SGR  2 ; [console]::Write(" - demibold (faint boldface)") ;
            SGR 22 ; [console]::Write(" - not boldface nor demibold") ;
            pseudoSGR0
        CUP  5 4 ;
            SGR  3 ; [console]::Write("Italic medium (normal)")
            SGR  2 ; [console]::Write(" - light (faint normal)") ;
            SGR 22 ; [console]::Write(" - not light") ;
            pseudoSGR0
        CUP  7 4 ; SGR  3 ; [console]::Write("Italic") ; SGR 23 ; [console]::Write(" - no italic") ; pseudoSGR0
        CUP  8 4 ;
            SGR 10 ; [console]::Write("SGR 10") ; pseudoSGR0 ; [console]::Write(" - ")
            SGR 11 ; [console]::Write("SGR 11") ; pseudoSGR0 ; [console]::Write(" - ")
            SGR 12 ; [console]::Write("SGR 12") ; pseudoSGR0 ; [console]::Write(" - ")
            SGR 13 ; [console]::Write("SGR 13") ; pseudoSGR0 ; [console]::Write(" - ")
            SGR 14 ; [console]::Write("SGR 14") ; pseudoSGR0 ; [console]::Write(" - ")
            SGR 15 ; [console]::Write("SGR 15") ; pseudoSGR0 ; [console]::Write(" - ")
            SGR 16 ; [console]::Write("SGR 16") ; pseudoSGR0 ; [console]::Write(" - ")
            SGR 17 ; [console]::Write("SGR 17") ; pseudoSGR0 ; [console]::Write(" - ")
            SGR 18 ; [console]::Write("SGR 18") ; pseudoSGR0 ; [console]::Write(" - ")
            SGR 19 ; [console]::Write("SGR 19") ; pseudoSGR0 ; #[console]::Write(" - ")


    CUP 10 0 ; [console]::Write("Standard attributes:")
        CUP 11 4 ; SGR  4 ; [console]::Write("Underline") ; SGR 24 ; [console]::Write(" - no underline") ; pseudoSGR0
        CUP 12 4 ; SGR  5 ; [console]::Write("Slow blink") ; SGR 25 ; [console]::Write(" - no slow blink") ; pseudoSGR0
        CUP 13 4 ; SGR  6 ; [console]::Write("Rapid blink") ; SGR 26 ; [console]::Write(" - no rapid blink") ; pseudoSGR0
        CUP 14 4 ; SGR  7 ; [console]::Write("Inverse") ; SGR 27 ; [console]::Write(" - no inverse") ; pseudoSGR0
        CUP 15 4 ; SGR  8 ; [console]::Write("Invisible") ; SGR 28 ; [console]::Write(" - no invisible") ; pseudoSGR0
        CUP 16 4 ; SGR  9 ; [console]::Write("Strikethrough") ; SGR 29 ; [console]::Write(" - no strikethrough") ; pseudoSGR0
        CUP 17 4 ; SGR 53 ; [console]::Write("Overline") ; SGR 55 ; [console]::Write(" - no overline") ; pseudoSGR0
        CUP 18 4 ; SGR 51 ; [console]::Write("Framed") ; SGR 54 ; [console]::Write(" - not framed") ; pseudoSGR0
        CUP 19 4 ; SGR 52 ; [console]::Write("Encircled") ; SGR 54 ; [console]::Write(" - not encircled") ; pseudoSGR0

    $fgName = $script:foreground_colour_combobox.Text
    $bgName = $script:background_colour_combobox.Text
    CUP 21 0
        pseudoSGR0 ; [console]::Write("ISO colours: ") ; pseudoSGR0
        CUP 21 13 ; SGR $script:fg_colour ; [console]::Write("##") ; pseudoSGR0 ; [console]::Write(" $fgName ($script:fg_colour)")
        CUP 21 28 ;[console]::Write(" on ")
        SGR $script:bg_colour ; [console]::Write("  ") ; pseudoSGR0 ; [console]::Write(" $bgName ($script:bg_colour)")
        CUP 21 47 ; [console]::Write(" gives ")
        SGR $script:fg_colour $script:bg_colour ; [console]::Write("this") ; pseudoSGR0
        pseudoSGR0

# See https://github.com/kovidgoyal/kitty/issues/226
    CUP 23 0 ; [console]::Write("SGR 4 extensions to provide underline variants: ") ;
    CUP 24 4
        SGR $(ECMA48SubParams 4 $null) ; [console]::Write("empty-default ") ; SGR 26
        SGR $(ECMA48SubParams 4 0) ; [console]::Write("zero-default ") ; SGR 26
        SGR $(ECMA48SubParams 4 1) ; [console]::Write("single ") ; SGR 26
        SGR $(ECMA48SubParams 4 2) ; [console]::Write("double ") ; SGR 26
        SGR $(ECMA48SubParams 4 3) ; [console]::Write("scurly ") ; SGR 26
        SGR $(ECMA48SubParams 4 4) ; [console]::Write("dotted ") ; SGR 26
        SGR $(ECMA48SubParams 4 5) ; [console]::Write("dashed ") ; SGR 26
        SGR $(ECMA48SubParams 4 6) ; [console]::Write("ldashed ") ; SGR 26
        SGR $(ECMA48SubParams 4 7) ; [console]::Write("lldashed ") ; SGR 26
        SGR $(ECMA48SubParams 4 8) ; [console]::Write("ldotted ") ; SGR 26
        SGR $(ECMA48SubParams 4 9) ; [console]::Write("lcurly ") ; SGR 26
        pseudoSGR0

    SGR
    CUP 25 0
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

$background_checkbox = New-Object System.Windows.Forms.CheckBox
$background_checkbox.Text = "Light background (inverse video, DEC mode 5)"
$background_checkbox.AutoSize = $true
$background_checkbox.Top = $csi_label.Top + $vertical_grid + 10
$background_checkbox.Left = $csi_label.Left

# colour selectors
$colours = @('Black', 'Red', 'Green', 'Yellow', 'Blue', 'Magenta', 'Cyan', 'White', 'Default')
function indexToColour($index, $fg){
    if($index -ge 8 -or $index -lt 0) {
        $index = 9; # clamp to "default"
    }
    $index + ($fg ? 30 : 40)
}
function makeColourCB($fg){
    $cb = New-Object System.Windows.Forms.ComboBox
    $cb.AutoSize = $true
    foreach($colour in $script:colours){
        $cb.Items.Add($colour) | Out-Null
    }
    $cb.SelectedIndex = 8;
    $cb.add_SelectedIndexChanged($fg ? {
        $script:fg_colour = ($script:foreground_colour_combobox.SelectedIndex + 0) + 30;
        Click
    } : {
        $script:bg_colour = ($script:background_colour_combobox.SelectedIndex + 0) + 40;
        Click
    })
    return $cb
}

$foreground_colour_combobox = makeColourCB($true)
$foreground_colour_combobox.Top = $background_checkbox.Top + $vertical_grid + 10
$foreground_colour_combobox.Left = $background_checkbox.Left

$background_colour_combobox = makeColourCB($false)
$background_colour_combobox.Top = $foreground_colour_combobox.Top + $vertical_grid + 10
$background_colour_combobox.Left = $foreground_colour_combobox.Left

$colour_all_checkbox = New-Object System.Windows.Forms.CheckBox
$colour_all_checkbox.Text = "Colour all text"
$colour_all_checkbox.AutoSize = $true
$colour_all_checkbox.Top = $background_colour_combobox.Top + $vertical_grid + 10
$colour_all_checkbox.Left = $background_colour_combobox.Left

# main form

$form = New-Object System.Windows.Forms.Form
$form.Controls.Add($csi_label)
$form.Controls.Add($csi_groupbox)
$form.Controls.Add($background_checkbox)
$form.Controls.Add($foreground_colour_combobox)
$form.Controls.Add($background_colour_combobox)
$form.Controls.Add($colour_all_checkbox)
$form.Text = "SGR attributes test"
$form.AutoSize = $true
$form.Opacity = 0.9

# events

function Click {
    C1
    $script:scnm = $script:background_checkbox.Checked
    $script:colour_all = $script:colour_all_checkbox.Checked
    Do-It
}

if ([Console]::OutputEncoding.IsSingleByte) {
    $csi7_radiobutton.Checked = $true
} else {
    $csi8_radiobutton.Checked = $true
}
$scnm = $false
$background_checkbox.Checked = $true
$colour_all = $false
$fg_colour = 39
$bg_colour = 49

$csi7_radiobutton.add_Click({Click})
$csi8_radiobutton.add_Click({Click})
$csiu_radiobutton.add_Click({Click})
$background_checkbox.add_Click({Click})
$colour_all_checkbox.add_Click({Click})

Click

$r = $form.ShowDialog()
