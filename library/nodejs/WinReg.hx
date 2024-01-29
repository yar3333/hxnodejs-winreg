package nodejs;

import js.lib.Error;
import js.node.ChildProcess;
using StringTools;

class WinReg
{
    /**
        `fullKey` example: "HKLM:/Software/MyProject/MyRegistryKey"
    **/
    public static function getKeyValue(fullKey:String) : String
    {
        fullKey = fullKey.replace("/", "\\");

        var n = fullKey.lastIndexOf("\\");
        var keyPath = fullKey.substr(0, n).replace("\\", "\\\\");
        var keyName = fullKey.substr(n + 1);

        var r = runPowerShell("
            $ErrorActionPreference = 'Stop'
            $keyPath = \"" + keyPath + "\"
            $key = \"" + keyName + "\"
    
            try {
                $value = Get-ItemProperty -Path $keyPath -Name $key
                if ($value -ne $null) {
                    Write-Output $value.$key
                } else {
                    Write-Output \"---NOT_FOUND\"
                }
            } catch {
                Write-Output \"---ERROR: $_\"
            }
        ").toString();

        return r;
    }

    private static function runPowerShell(script:String) : String
    {
        var r = ChildProcess.execSync(script, { shell: 'powershell.exe' });
        if (r == "---NOT_FOUND") return null;
        if (r.startsWith("---ERROR:")) throw new Error(r);
        return r;
    }
}