function createIdxVariables() {
    $vars = ""
    $browserIdxs |
    % {}{
        $browserIdx = $_
        $varName = $browserNames[$browserIdx].ToLower() + "Idx"
        $varValue = $browserIdxs[$browserIdx]
        $var = "	const $($varName) = $($varValue);`r`n"
        $vars += $var
    }{
        $vars = $vars -replace "\r\n$", ""
    }
    return $vars
}
function createBrowserNamesVariable() {
    $var = ""
    $var += "	const browserNames = [`r`n"
    $browserIdxs |
    % {
        $browserIdx = $_
        $var += "		`"$($browserNames[$browserIdx])`",`r`n"
    }
    $var += "	];"
    return $var
}
function createImgNamesVariable() {
    $var = ""
    $var += "	const imgNames = [`r`n"
    $browserIdxs |
    % {
        $browserIdx = $_
        $var += "		[`r`n"
        getFuncFolders $browserIdx |
        % {
            getScreenFolders $_.FullName |
            % {
                $screenPath = toShortcutDestinationPath $_.FullName
                $targetExtension = "jpg"
                $var += "			["
                getScreenFiles $screenPath $targetExtension |
                % {
                    $imgName = $_.Name
                    $var += "`"$($imgName)`", "
                }
                $var += "],`r`n"
            }
        }
        $var += "		],`r`n"
    }
    $var += "	];"
    return $var
}
function createImgPathsVariable() {
    $var = ""
    $var += "	const imgPaths = [`r`n"
    $browserIdxs |
    % {
        $browserIdx = $_
        $var += "		[`r`n"
        getFuncFolders $browserIdx |
        % {
            getScreenFolders $_.FullName |
            % {
                $screenPath = toShortcutDestinationPath $_.FullName
                $targetExtension = "jpg"
                $var += "			["
                getScreenFiles $screenPath $targetExtension |
                % {
                    $imgPath = $_.FullName
                    $imgPath = $imgPath.Replace("\", "\\")
                    $imgPath = "<img src=\`"$($imgPath)\`">"
                    $var += "`"$($imgPath)`", "
                }
                $var += "],`r`n"
            }
        }
        $var += "		],`r`n"
    }
    $var += "	];"
    return $var
}
function createFileNamesVariable() {
    $var = ""
    $var += "	const fileNames = [`r`n"
    $browserIdxs |
    % {
        $browserIdx = $_
        $var += "		[`r`n"
        getFuncFolders $browserIdx |
        % {
            getScreenFolders $_.FullName |
            % {
                $screenPath = toShortcutDestinationPath $_.FullName
                $targetExtension = "log"
                $var += "			["
                getScreenFiles $screenPath $targetExtension |
                % {
                    $fileName = $_.Name
                    $var += "`"$($fileName)`", "
                }
                $var += "],`r`n"
            }
        }
        $var += "		],`r`n"
    }
    $var += "	];"
    return $var
}
function createFolderPathsVariable() {
    $var = ""
    $var += "	const folderPaths = [`r`n"
    $browserIdxs |
    % {
        $browserIdx = $_
        $var += "		[`r`n"
        getFuncFolders $browserIdx |
        % {
            getScreenFolders $_.FullName |
            % {
                $screenPath = $_.FullName
                $encoded = ([System.Text.Encoding]::Default).GetBytes($screenPath)
                $encoded = [Convert]::ToBase64String($encoded)
                $var += "			`"$($encoded)`",`r`n"
            }
        }
        $var += "		],`r`n"
    }
    $var += "	];"
    return $var
}
function getFuncFolders($browserIdx) {
    return Get-ChildItem -LiteralPath "$($browserPaths[$browserIdx])" -Directory | Sort-Object -Property Name
}
function getScreenFolders($funcPath) {
    return Get-ChildItem -LiteralPath "$($funcPath)" -Directory | Sort-Object -Property Name
}
function getScreenFiles($screenPath, $targetExtension) {
    return @(Get-ChildItem -LiteralPath "$($screenPath)" -Filter "*.$($targetExtension)" -Recurse) | Sort-Object -Property FullName
}
function toShortcutDestinationPath($originalPath) {
    $lnk = Get-ChildItem -LiteralPath "$($originalPath)" -Filter *.lnk
    if ($lnk -eq $null) { return $originalPath }
    $lnk |
    % {
        $shell = New-Object -ComObject Shell.Application
        $lnkFolder = $shell.NameSpace($_.DirectoryName)
        $lnkFile = $lnkFolder.ParseName($_.Name)
        $destPath = $lnkFolder.GetDetailsOf($lnkFile, 203)
        return $destPath
    }
}
function createImgTableDivision() {
    $div = ""
    $div += "<div>`r`n"
    $browserIdxs |
    % {
        $browserIdx = $_
        $browserIdxName = $browserNames[$browserIdx].ToLower() + "Idx"
        $div += "	<div>`r`n"
        $div += "		`${createImgTable($($browserIdxName), screenIdx)}`r`n"
        $div += "	</div>`r`n"
    }
    $div += "</div>"
    return $div
}
function createFileTableDivision() {
    $div = ""
    $div += "<div>`r`n"
    $browserIdxs |
    % {
        $browserIdx = $_
        $browserIdxName = $browserNames[$browserIdx].ToLower() + "Idx"
        $div += "	`${createFileTable($($browserIdxName), screenIdx)}`r`n"
    }
    $div += "</div>"
    return $div
}
function createLinkHrefs() {
    $hrefs = ""
    $browserIdxs |
    % {}{
        $browserIdx = $_
        $browserIdxName = $browserNames[$browserIdx].ToLower() + "Idx"
        $hrefs += "		links[$($browserIdxName)].href = ``OpenFolder:`${folderPaths[$($browserIdxName)][screenIdx]}``;`r`n"
    }{
        $hrefs = $hrefs -replace "\r\n$", ""
    }
    return $hrefs
}
function createMenu() {
    $menu = ""
    getFuncFolders($ieIdx) |
    % {}{
        $funcName = $_.Name
        $funcPath = $_.FullName
        $menu += "			<div>`r`n"
        $menu += "				<a>$($funcName)</a>`r`n"
        $menu += "				<ul>`r`n"
        getScreenFolders($funcPath) |
        % {
            $screenName = $_.Name
            $menu += "					<li><a>$($screenName)</a></li>`r`n"
        }
        $menu += "				</ul>`r`n"
        $menu += "			</div>`r`n"
    }{
        $menu = $menu -replace "\r\n$", ""
    }
    return $menu
}

$ieIdx = 0
$chromeIdx = 1
$newchromwIdx = 2
$browserIdxs = @($ieIdx, $chromeIdx, $newchromwIdx)
$browserNames = @("IE", "Chrome", "newChrome")
$browserPaths = @("C:\Users\yamane\Desktop\画像比較(IE-Chrome)\IE", "C:\Users\yamane\Desktop\画像比較(IE-Chrome)\Chrome", "C:\Users\yamane\Desktop\画像比較(IE-Chrome)\Chrome - コピー")
$fileTableShows = $false
$html = @"
<!doctype html>
<html>
<head>
	<style>
	#blockContainer {
		width: 98vw;
		height: 95vh;
		display: flex;
	}
	#menuBlock {
		width: 15%;
		height: 100%;
		overflow: scroll;
		white-space: nowrap;
	}
	#menuBlock ul {
		list-style: none;
		display: none;
	}
	#btnBlock {
		width: 5%;
		height: 100%;
	}
	#btnBlock button {
		width: 100%;
		height: 100%;
		max-width: 28px;
	}
	#tblBlock {
		width: 80%;
		height: 100%;
		overflow-x: scroll;
		display: flex;
	}
	#tblBlock > div { display: flex; }
	#tblBlock > div > div {
		height: 100%;
		overflow-y: scroll;
	}
	#tblBlock table { border-collapse: collapse; }
	#tblBlock table th, #tblBlock table td { border: 1px solid #000; }
	#tblBlock img { width: 300px; }
	.red { color: red; }
	.empty { height: 100vh; }
	</style>
	<script>
$(createIdxVariables)
$(createBrowserNamesVariable)
$(createFolderPathsVariable)
$(createImgNamesVariable)
$(createImgPathsVariable)
$(createFileNamesVariable)
	document.addEventListener("DOMContentLoaded", () => {
		const links = document.querySelectorAll("#menuBlock a");
		const downloadLink = document.querySelector("#menuBlock > a");
		const menu = document.querySelectorAll("#menuBlock > div > a");
		const submenu = document.querySelectorAll("#menuBlock li > a");
		const btn = document.querySelector("#btnBlock > button");
		document.addEventListener("keydown", (e) => {
			if (e.key == "a") { switchMenu(); }
		});
		links.forEach((link) => {
			link.href = "javascript:void(0);";
		});
		downloadLink.addEventListener("click", (e) => {
			downloadRegistryFile(e.target);
		});
		menu.forEach((menuItem) => {
			menuItem.addEventListener("click", (e) => {
				switchSubmenu(e.target);
			});
		});
		submenu.forEach((submenuItem) => {
			submenuItem.addEventListener("click", (e) => {
				changeColor(e.target);
				changeTable(e.target);
			});
		});
		btn.addEventListener("click", () => {
			switchMenu();
		});
	});
	function downloadRegistryFile(downloadLink) {
		const bom  = new Uint8Array([0xFF, 0xFE]);
		const text = (() => {
			let text = "";
			text += "Windows Registry Editor Version 5.00\r\n\r\n";
			text += "[HKEY_CLASSES_ROOT\\\OpenFolder]\r\n";
			text += "@=\"URL:OpenFolder Protocol\"\r\n";
			text += "\"URL Protocol\"=\"\"\r\n\r\n";
			text += "[HKEY_CLASSES_ROOT\\OpenFolder\\shell]\r\n\r\n";
			text += "[HKEY_CLASSES_ROOT\\OpenFolder\\shell\\open]\r\n\r\n";
			text += "[HKEY_CLASSES_ROOT\\OpenFolder\\shell\\open\\command]\r\n";
			text += "@=\"cmd.exe /c powershell -command \\\"`$path = '%1'.Substring(11); `$path = [System.Convert]::FromBase64String(`$path); `$path = [System.Text.Encoding]::Default.GetString(`$path); explorer.exe `$path\\\"\"\r\n\r\n";
			return text;
		})();
		const array = Uint16Array.from(text.split(''), c => c.charCodeAt(0));
		const blob = new Blob([bom, array], {"type": "text/plain"});
		downloadLink.download = "openFolder.reg";
		downloadLink.href = window.URL.createObjectURL(blob);
	}
	function switchMenu() {
		const menuIsOpen = menuBlock.style.display != "none";
		menuBlock.style.display = menuIsOpen ? "none" : "block";
		tblBlock.style.width = menuIsOpen ? "95%" : "80%";
		if (menuIsOpen) { document.querySelector(".red").focus(); }
	}
	function switchSubmenu(menu) {
		const submenu = menu.nextElementSibling;
		const ss = submenu.style;
		ss.display == "block" ? ss.display = "none" : ss.display = "block";
	}
	function changeColor(submenu) {
		const redElem = document.querySelector(".red");
		if (redElem) { redElem.classList.remove("red"); }
		submenu.classList.add("red");
	}
	function changeTable(submenu) {
		const screenIdx = ((submenu) => {
			let submenus = menuBlock.getElementsByTagName('li');
			submenus = [].slice.call(submenus);
			const idx = submenus.indexOf(submenu.parentElement);
			return idx;
		})(submenu);
		const html = ``
$(createImgTableDivision)
$(if ($fileTableShows) {createFileTableDivision})
``;
		tblBlock.textContent = "";
		tblBlock.insertAdjacentHTML("beforeend", html);
		setLink(screenIdx);
		setScrollEvent();
	}
	function createImgTable(browserIdx, screenIdx) {
		let html = "";
		html += "<table>\r\n";
		html += ``	<tr><th><a>`${browserNames[browserIdx]}</a></th></tr>\r\n``;
		for (let imgIdx = 0; imgIdx < imgNames[browserIdx][screenIdx].length; imgIdx++) {
			html += ``	<tr><td>`${imgNames[browserIdx][screenIdx][imgIdx]}<br><a>`${imgPaths[browserIdx][screenIdx][imgIdx]}</a></td></tr>\r\n``;
		}
		html += "	<tr><td class=\"empty\"></td></tr>\r\n";
		html += "</table>";
		return html;
	}
	function createFileTable(browserIdx, screenIdx) {
		let html = "";
		html += "<table>\r\n";
		html += ``	<tr><th>`${browserNames[browserIdx]}</th></tr>\r\n``;
		for (let imgIdx = 0; imgIdx < fileNames[browserIdx][screenIdx].length; imgIdx++) {
			html += ``	<tr><th>`${fileNames[browserIdx][screenIdx][imgIdx]}</th></tr>\r\n``;
		}
		html += "</table>";
		return html;
	}
	function setLink(screenIdx) {
		const links = document.querySelectorAll("#tblBlock > div > div th a");
$(createLinkHrefs)
	}
	function setScrollEvent() {
		const imgs = document.querySelectorAll("#tblBlock > div > div img");
		imgs.forEach((img) => {
			img.addEventListener("click", (e) => {
				const tr = e.target.parentElement.parentElement.parentElement;
				const div = tr.parentElement.parentElement.parentElement;
				const distance = tr.getBoundingClientRect().top - div.getBoundingClientRect().top;
				div.scrollBy(0, distance);
			});
		});
	}
	</script>
</head>
<body>
	<div id="blockContainer">
		<div id="menuBlock">
			<a>regファイル</a>
$(createMenu)
		</div>
		<div id="btnBlock">
			<button>開<br>閉</button>
		</div>
		<div id="tblBlock">
		</div>
	</div>
</body>
</html>
"@

Set-Location $PSScriptRoot
Set-Content -LiteralPath ".\View.html" -Value $html -Encoding UTF8