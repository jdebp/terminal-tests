## COPYING ******************************************************************
## For copyright and licensing terms, see the file named LICENSE.
## **************************************************************************

## A test of SGR character attributes
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

function Do-It {
    CUP
    SGR
	DECSCNM $($script:scnm -gt 0)
    ED 2

    CUP  1 0 ; [console]::Write("Font weights and slants:") 
        CUP  2 4 ; 
            SGR  1 ; [console]::Write("Upright boldface") ; 
            SGR  2 ; [console]::Write(" - demibold (faint boldface)") ; 
            SGR 22 ; [console]::Write(" - not boldface nor demibold") ; 
            SGR 0
        CUP  3 4 ; 
            SGR  0 ; [console]::Write("Upright medium (normal)") 
            SGR  2 ; [console]::Write(" - light (faint normal)") ; 
            SGR 22 ; [console]::Write(" - not light") ; 
            SGR 0
        CUP  4 4 ; 
            SGR  1 3 ; [console]::Write("Italic boldface") ; 
            SGR  2 ; [console]::Write(" - demibold (faint boldface)") ; 
            SGR 22 ; [console]::Write(" - not boldface nor demibold") ; 
            SGR 0
        CUP  5 4 ; 
            SGR  3 ; [console]::Write("Italic medium (normal)") 
            SGR  2 ; [console]::Write(" - light (faint normal)") ; 
            SGR 22 ; [console]::Write(" - not light") ; 
            SGR 0
        CUP  7 4 ; SGR  3 ; [console]::Write("Italic") ; SGR 23 ; [console]::Write(" - no italic") ; SGR 0
        CUP  8 4 ; 
            SGR 10 ; [console]::Write("SGR 10") ; SGR 0 ; [console]::Write(" - ")
            SGR 11 ; [console]::Write("SGR 11") ; SGR 0 ; [console]::Write(" - ")
            SGR 12 ; [console]::Write("SGR 12") ; SGR 0 ; [console]::Write(" - ")
            SGR 13 ; [console]::Write("SGR 13") ; SGR 0 ; [console]::Write(" - ")
            SGR 14 ; [console]::Write("SGR 14") ; SGR 0 ; [console]::Write(" - ")
            SGR 15 ; [console]::Write("SGR 15") ; SGR 0 ; [console]::Write(" - ")
            SGR 16 ; [console]::Write("SGR 16") ; SGR 0 ; [console]::Write(" - ")
            SGR 17 ; [console]::Write("SGR 17") ; SGR 0 ; [console]::Write(" - ")
            SGR 18 ; [console]::Write("SGR 18") ; SGR 0 ; [console]::Write(" - ")
            SGR 19 ; [console]::Write("SGR 19") ; SGR 0 ; #[console]::Write(" - ")
        

    CUP 10 0 ; [console]::Write("Standard attributes:") 
        CUP 11 4 ; SGR  4 ; [console]::Write("Underline") ; SGR 24 ; [console]::Write(" - no underline") ; SGR 0
        CUP 12 4 ; SGR  5 ; [console]::Write("Slow blink") ; SGR 25 ; [console]::Write(" - no blink") ; SGR 0
        CUP 13 4 ; SGR  6 ; [console]::Write("Rapid blink") ; SGR 25 ; [console]::Write(" - no blink") ; SGR 0
        CUP 14 4 ; SGR  7 ; [console]::Write("Inverse") ; SGR 27 ; [console]::Write(" - no inverse") ; SGR 0
        CUP 15 4 ; SGR  8 ; [console]::Write("Invisible") ; SGR 28 ; [console]::Write(" - no invisible") ; SGR 0
        CUP 16 4 ; SGR  9 ; [console]::Write("Strikethrough") ; SGR 29 ; [console]::Write(" - no strikethrough") ; SGR 0
        CUP 17 4 ; SGR 53 ; [console]::Write("Overline") ; SGR 55 ; [console]::Write(" - no overline") ; SGR 0
        CUP 18 4 ; SGR 51 ; [console]::Write("Framed") ; SGR 54 ; [console]::Write(" - not framed") ; SGR 0
        CUP 19 4 ; SGR 52 ; [console]::Write("Encircled") ; SGR 54 ; [console]::Write(" - not encircled") ; SGR 0
        
    
# See https://github.com/kovidgoyal/kitty/issues/226
    CUP 21 0 ; [console]::Write("SGR 4 extensions to provide underline variants: ") ; 
    CUP 22 4
        SGR $(ECMA48SubParams 4 $null) ; [console]::Write("empty-default ") ; SGR 24
        SGR $(ECMA48SubParams 4 0) ; [console]::Write("zero-default ") ; SGR 24
        SGR $(ECMA48SubParams 4 1) ; [console]::Write("single ") ; SGR 24
        SGR $(ECMA48SubParams 4 2) ; [console]::Write("double ") ; SGR 24
        SGR $(ECMA48SubParams 4 3) ; [console]::Write("scurly ") ; SGR 24
        SGR $(ECMA48SubParams 4 4) ; [console]::Write("dotted ") ; SGR 24
        SGR $(ECMA48SubParams 4 5) ; [console]::Write("dashed ") ; SGR 24
        SGR $(ECMA48SubParams 4 6) ; [console]::Write("ldashed ") ; SGR 24
        SGR $(ECMA48SubParams 4 7) ; [console]::Write("lldashed ") ; SGR 24
        SGR $(ECMA48SubParams 4 8) ; [console]::Write("ldotted ") ; SGR 24
        SGR $(ECMA48SubParams 4 9) ; [console]::Write("lcurly ") ; SGR 24
        SGR 0
    
    SGR
    CUP 23 0
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

# main form

$form = New-Object System.Windows.Forms.Form
$form.Controls.Add($csi_label)
$form.Controls.Add($csi_groupbox)
$form.Controls.Add($background_checkbox)
$form.Text = "SGR attributes test"
$form.AutoSize = $true
$form.Opacity = 0.9

# events

function Click {
    C1
    $script:scnm = $script:background_checkbox.Checked
    Do-It
}

if ([Console]::OutputEncoding.IsSingleByte) {
    $csi7_radiobutton.Checked = $true
} else {
    $csi8_radiobutton.Checked = $true
}
$scnm = $false
$background_checkbox.Checked = $true

$csi7_radiobutton.add_Click({Click})
$csi8_radiobutton.add_Click({Click})
$csiu_radiobutton.add_Click({Click})
$background_checkbox.add_Click({Click})

Click

$r = $form.ShowDialog()