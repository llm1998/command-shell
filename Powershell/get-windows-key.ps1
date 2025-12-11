function Get-WindowsKey {
    $hklm = 2147483650
    $regPath = "Software\Microsoft\Windows NT\CurrentVersion"
    $regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($hklm, "").OpenSubKey($regPath)
    $value = $regKey.GetValue("DigitalProductId")

    if ($value) {
        $ProductName = $regKey.GetValue("ProductName")
        $ProductId = $regKey.GetValue("ProductId")
        $DigitalProductId = $value

        function ConvertTo-Key {
            param($DigitalProductId)
            $Key = ""
            $Chars = "BCDFGHJKMPQRTVWXY2346789"
            $IsWin8OrUp = ($DigitalProductId[66] -band 0xF0) -eq 0

            $KeyOffset = 52
            $isWin8 = (($DigitalProductId[66] -band 0xF0) -eq 0xF0)
            $DigitalProductId = $DigitalProductId[52..(52 + 15)]
            for ($i = 24; $i -ge 0; $i--) {
                $Current = 0
                for ($j = 14; $j -ge 0; $j--) {
                    $Current = $Current * 256 -bxor $DigitalProductId[$j]
                    $DigitalProductId[$j] = [math]::Floor($Current / 24)
                    $Current = $Current % 24
                }
                $Key = $Chars[$Current] + $Key
                if (($i % 5 -eq 0) -and ($i -ne 0)) {
                    $Key = "-" + $Key
                }
            }
            return $Key
        }

        [PSCustomObject]@{
            'Product Name' = $ProductName
            'Product ID'   = $ProductId
            'Installed Key' = (ConvertTo-Key $DigitalProductId)
        }
    } else {
        Write-Output "Chave não encontrada."
    }
}

Get-WindowsKey
