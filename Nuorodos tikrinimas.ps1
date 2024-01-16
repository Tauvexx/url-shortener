Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Net.Http

function IsValidUri($url) {
    if ($url -match '^(https?://)?[\w.-]+\.[a-z]{2,}(/.*)?$') {
        return $true
    }

    return $false
}

function Show-Gui {
    [System.Windows.Forms.Application]::EnableVisualStyles()

    function New-ShortUrl {
        param (
            [string]$Url
        )

        $tinyUrlApi = 'http://tinyurl.com/api-create.php'
        $response = Invoke-WebRequest ("{0}?url={1}" -f $tinyUrlApi, $Url)
        $response.Content
    }

    function Get-OriginalUrl {
        param (
            [string]$ShortUrl
        )

        $web = Invoke-WebRequest -Uri $ShortUrl -UseBasicParsing
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $web.BaseResponse.ResponseUri.AbsoluteUri
    }

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "URL trumpiklis"
    $form.Width = 500
    $form.Height = 200

    # Add PictureBox for the logo
    $pictureBox = New-Object System.Windows.Forms.PictureBox
    $imageStream = (Invoke-WebRequest -Uri "https://imgur.com/yKTGuI6.png" -UseBasicParsing).RawContentStream
    $pictureBox.Image = [System.Drawing.Image]::FromStream($imageStream)
    $pictureBox.Location = New-Object System.Drawing.Point(350, 10)
    $pictureBox.Size = New-Object System.Drawing.Size(60, 60)
    $pictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point(10, 20)
    $textBox.Size = New-Object System.Drawing.Size(300, 20)

    $buttonGenerate = New-Object System.Windows.Forms.Button
    $buttonGenerate.Location = New-Object System.Drawing.Point(10, 60)
    $buttonGenerate.Size = New-Object System.Drawing.Size(80, 30)
    $buttonGenerate.Text = "Generuoti"
    $buttonGenerate.Add_Click({
        $url = $textBox.Text
        if (IsValidUri $url) {
            try {
                $shortUrl = New-ShortUrl -Url $url
                $textBox.Text = $shortUrl
            } catch {
                [System.Windows.Forms.MessageBox]::Show("Klaida generuojant nuorodą: $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("$url Bloga nuorodą", "Netinkamas URL", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })

    $buttonCheck = New-Object System.Windows.Forms.Button
    $buttonCheck.Location = New-Object System.Drawing.Point(100, 60)
    $buttonCheck.Size = New-Object System.Drawing.Size(80, 30)
    $buttonCheck.Text = "Tikrinti"
    $buttonCheck.Add_Click({
        $shortUrl = $textBox.Text
        if (IsValidUri $shortUrl) {
            try {
                $originalUrl = Get-OriginalUrl -ShortUrl $shortUrl
                [System.Windows.Forms.MessageBox]::Show("Originali nuorodą: $originalUrl", "Tikra nuoroda", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            } catch {
                [System.Windows.Forms.MessageBox]::Show("Error checking original URL: $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("$shortUrl Netinkama nuoroda", "Netinkamas URL", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })

    $form.Controls.Add($pictureBox)
    $form.Controls.Add($textBox)
    $form.Controls.Add($buttonGenerate)
    $form.Controls.Add($buttonCheck)

    $form.ShowDialog()
}

# Call the GUI function
Show-Gui
