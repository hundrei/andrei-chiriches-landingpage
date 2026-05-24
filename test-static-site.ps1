$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$indexPath = Join-Path $root "index.html"
$impressumPath = Join-Path $root "impressum.html"
$datenschutzPath = Join-Path $root "datenschutz.html"
$cnamePath = Join-Path $root "CNAME"
$sitemapPath = Join-Path $root "sitemap.xml"
$robotsPath = Join-Path $root "robots.txt"
$llmsPath = Join-Path $root "llms.txt"
$stylesPath = Join-Path $root "styles.css"
$assetsPath = Join-Path $root "assets"
$portraitPath = Join-Path $assetsPath "andrei-chiriches-portrait.jpeg"
$aboutPortraitPath = Join-Path $assetsPath "ich.png"
$contactSignalPath = Join-Path $assetsPath "contact-signal.svg"
$topicsGraphicPath = Join-Path $assetsPath "topics-barriers.svg"
$faviconPath = Join-Path $assetsPath "favicon.png"
$utf8 = [System.Text.UTF8Encoding]::new($false, $true)
$ae = [char]0x00E4
$oe = [char]0x00F6
$ue = [char]0x00FC
$Ae = [char]0x00C4
$Oe = [char]0x00D6
$Ue = [char]0x00DC
$ss = [char]0x00DF
$sComma = [char]0x0219

function Assert-True($condition, $message) {
    if (-not $condition) {
        throw $message
    }
}

function Read-Utf8($path) {
    return [System.IO.File]::ReadAllText($path, $utf8)
}

Assert-True (Test-Path $indexPath) "index.html is missing"
Assert-True (Test-Path $impressumPath) "impressum.html is missing"
Assert-True (Test-Path $datenschutzPath) "datenschutz.html is missing"
Assert-True (Test-Path $cnamePath) "CNAME is missing"
Assert-True (Test-Path $sitemapPath) "sitemap.xml is missing"
Assert-True (Test-Path $robotsPath) "robots.txt is missing"
Assert-True (Test-Path $llmsPath) "llms.txt is missing"
Assert-True (Test-Path $stylesPath) "styles.css is missing"
Assert-True (Test-Path $assetsPath) "assets directory is missing"
Assert-True (Test-Path $portraitPath) "Portrait image is missing"
Assert-True (Test-Path $aboutPortraitPath) "About profile image is missing"
Assert-True (Test-Path $contactSignalPath) "Contact signal graphic is missing"
Assert-True (Test-Path $topicsGraphicPath) "Topics graphic is missing"
Assert-True (Test-Path $faviconPath) "Favicon logo is missing"

$html = Read-Utf8 $indexPath
$impressumHtml = Read-Utf8 $impressumPath
$datenschutzHtml = Read-Utf8 $datenschutzPath
$cname = (Read-Utf8 $cnamePath).Trim()
$sitemap = Read-Utf8 $sitemapPath
$robots = Read-Utf8 $robotsPath
$llms = Read-Utf8 $llmsPath
$css = Read-Utf8 $stylesPath
$contactSvg = Read-Utf8 $contactSignalPath
$topicsSvg = Read-Utf8 $topicsGraphicPath
$assetFiles = Get-ChildItem -LiteralPath $assetsPath -File
$plainText = ($html -replace "<[^>]+>", " ") -replace "\s+", " "
$impressumText = ($impressumHtml -replace "<[^>]+>", " ") -replace "\s+", " "
$datenschutzText = ($datenschutzHtml -replace "<[^>]+>", " ") -replace "\s+", " "

Assert-True ($html -match '<html lang="de">') "German document language is missing"
Assert-True ($cname -eq "andrei-chiriches.com") "GitHub Pages CNAME should point to andrei-chiriches.com"
Assert-True ($robots -match "User-agent: \*" -and $robots -match "Allow: /" -and $robots -match "Sitemap: https://andrei-chiriches\.com/sitemap\.xml" -and $robots -match "LLMs: https://andrei-chiriches\.com/llms\.txt") "robots.txt should allow crawling and reference the sitemap and llms file"
Assert-True ($sitemap -match "<urlset" -and $sitemap -match "xmlns:image" -and $sitemap -match "<loc>https://andrei-chiriches\.com/</loc>" -and $sitemap -match "<loc>https://andrei-chiriches\.com/impressum\.html</loc>" -and $sitemap -match "<loc>https://andrei-chiriches\.com/datenschutz\.html</loc>") "sitemap.xml should list the public pages and image namespace"
Assert-True ($sitemap -match "<image:loc>https://andrei-chiriches\.com/assets/andrei-chiriches-portrait\.jpeg</image:loc>") "sitemap.xml should declare the preferred search image"
Assert-True ($html -match '<meta charset="utf-8">') "UTF-8 charset is missing"
Assert-True ($html -match '<link rel="canonical" href="https://andrei-chiriches\.com/">') "Canonical link is missing from index"
Assert-True ($html -match 'property="og:title"' -and $html -match 'property="og:description"' -and $html -match 'property="og:image"' -and $html -match 'property="og:image:alt"' -and $html -match 'name="twitter:card"') "Social sharing meta tags are missing"
Assert-True ($html -match 'application/ld\+json' -and $html -match '"@type": "Person"' -and $html -match '"@type": "WebPage"' -and $html -match '"primaryImageOfPage"' -and $html -match '"jobTitle": "Keynote Speaker"' -and $html -match '"knowsAbout"') "Structured data is missing"
Assert-True ($html -match '"image": "https://andrei-chiriches\.com/assets/andrei-chiriches-portrait\.jpeg"' -and $html -notmatch '"image": "https://andrei-chiriches\.com/assets/ich\.png"') "Structured data should prefer the wheelchair portrait"
Assert-True ($llms -match "# Andrei Chiriches" -and $llms -match "KI, Behinderung und Teilhabe" -and $llms -match "https://andrei-chiriches\.com/" -and $llms -match "contact@andrei-chiriches\.com") "llms.txt should summarize the website for AI systems"
Assert-True ($html -match '<link rel="icon" type="image/png" sizes="576x576" href="/assets/favicon\.png">' -and $html -match '<link rel="shortcut icon" href="/assets/favicon\.png">' -and $html -match '<link rel="apple-touch-icon" href="/assets/favicon\.png">') "Favicon links are missing from index"
Assert-True ($impressumHtml -match '<link rel="icon" type="image/png" sizes="576x576" href="/assets/favicon\.png">' -and $datenschutzHtml -match '<link rel="icon" type="image/png" sizes="576x576" href="/assets/favicon\.png">') "Favicon links are missing from legal pages"
Assert-True ($plainText -match "Wenn KI Barrieren abbaut") "Hero headline is missing"
Assert-True ($plainText -match "Vortr${ae}ge" -and $plainText -match "${Ue}ber mich" -and $plainText -match "F${ue}r wen") "German umlauts are missing"
Assert-True ($plainText -match "Andrei Chiriche${sComma}") "Correct speaker name is missing"
Assert-True ($plainText -notmatch "Ã|È|â|Vortraege|Ueber|Fuer|fuer|ermoeglichen|staerken|koennen|tatsaechlich|veraendert") "Mojibake or ASCII transliterations appear in visible copy"

Assert-True ($html -match 'href="#top"' -and $html -match 'href="#vortraege"' -and $html -match 'href="#ueber-mich"' -and $html -match 'href="#faq"' -and $html -match 'href="#kontakt"') "Navigation anchors are incomplete"
Assert-True ([regex]::Matches($html, 'href="#kontaktformular"').Count -ge 2) "All external Vortrag anfragen CTA links should point to the contact form"
Assert-True ($html -match '<form[^>]+id="kontaktformular"') "Contact form is missing"
Assert-True ($html -match 'action="https://api\.web3forms\.com/submit"' -and $html -match 'method="POST"') "Contact form Web3Forms action is incomplete"
Assert-True ($html -match 'name="access_key" value="55e33674-da79-40ce-b053-f47f8709347f"') "Web3Forms access key is missing"
Assert-True ($html -match 'name="subject"' -and $html -match 'Neue Vortragsanfrage' -and $html -match 'andrei-chiriches\.com') "Web3Forms subject is missing"
Assert-True ($html -match 'name="botcheck"') "Web3Forms honeypot field is missing"
Assert-True ($html -match 'name="name"' -and $html -match 'name="email"' -and $html -match 'name="organisation"' -and $html -match 'name="message"') "Contact form fields are incomplete"
Assert-True ($html -match '<button class="button button-primary contact-submit" type="submit">Vortrag anfragen</button>') "Contact form submit button is missing"
Assert-True ($html -match 'id="form-status"' -and $html -match 'role="status"' -and $html -match 'Danke, Ihre Anfrage wurde gesendet') "Contact form confirmation message is missing"
Assert-True ($html -match 'fetch\(form\.action' -and $html -match 'new FormData\(form\)' -and $html -match 'form\.reset\(\)') "Contact form should submit via JavaScript and reset after success"
Assert-True ($html -match "mailto:contact@andrei-chiriches\.com") "Email link is missing"
Assert-True ($html -notmatch "kontakt@deinedomain\.de") "Placeholder email should not appear"
Assert-True ($html -match "linkedin\.com/in/andrei-chiriches") "LinkedIn link is missing"
Assert-True ($html -match 'href="impressum\.html"' -and $html -match 'href="datenschutz\.html"') "Legal footer links are missing"
Assert-True ([regex]::Matches($html, 'href="https://www\.linkedin\.com/in/andrei-chiriches/"[^>]*aria-label="LinkedIn Profil von Andrei Chiriche').Count -ge 2) "Header and footer LinkedIn icon links are missing"
Assert-True ($html -match 'class="header-actions"' -and $html -match 'class="footer-actions"' -and $html -match 'class="linkedin-icon"') "LinkedIn icon layout is missing"
Assert-True ($css -match "#0A66C2") "LinkedIn icon should use official LinkedIn blue"
Assert-True ($html -match "assets/andrei-chiriches-portrait\.jpeg" -and $html -match 'alt="Andrei Chiriche') "Hero portrait image is missing"
Assert-True ($html -match '<div class="about-side">\s*<p class="section-label">[^<]+</p>\s*<div class="about-visual">\s*<img src="assets/ich\.png" alt="Andrei Chiriche') "About profile image should use the round image below the red label"
Assert-True ($html -notmatch 'about-visual" aria-hidden="true"') "About profile image must not be hidden from assistive technology"
Assert-True ($html -notmatch 'assets/perspective-grid\.svg') "Abstract about image should not be used in visible markup"
Assert-True ($css -notmatch "\.about-visual\s*\{[^}]*border-left") "About profile image should not have a red side band"
Assert-True ($css -match "\.about-side" -and $css -match "\.about-copy" -and $css -match "max-width: 860px") "About layout should place image left and use a wider right-side copy column"

Assert-True ($plainText -match "Viele sprechen ${ue}ber KI" -and $plainText -match "Seit 2018 arbeite ich Vollzeit") "Updated topic context is missing"
Assert-True ($html -match '<section class="page-section centered-section" aria-labelledby="why-title">') "Why section should be centered"
Assert-True ($html -notmatch '<div class="two-column-text">') "Why section should not use a two-column text grid"
Assert-True ($css -match "\.centered-section" -and $css -match "text-align: center" -and $css -match "justify-items: center") "Centered section styles are missing"
Assert-True ($plainText -match "Ein Sprung ins Wasser hat mein Leben ver${ae}ndert" -and $plainText -match "2008 f${ue}hrte ein Badeunfall zu einer Querschnittl${ae}hmung") "Updated about intro is missing"
Assert-True ($plainText -match "Keine KI-Tools" -and $plainText -match "weniger technologische Freiheit") "Updated about technology context is missing"
Assert-True ($plainText -match "Ich lernte Deutsch" -and $plainText -match "Sprach- und Textwissenschaften") "Updated about education text is missing"
Assert-True ($plainText -match "KI ist f${ue}r mich kein abstraktes Zukunftsthema" -and $plainText -match "Menschen, Technologie und Teilhabe zusammengedacht werden") "Updated about closing text is missing"
Assert-True ($plainText -notmatch "Ich bin Andrei Chiriche" -and $plainText -notmatch "Meine Perspektive entsteht aus echter Erfahrung") "Old about text should not remain"
Assert-True ($html -match '<section class="audience-band" aria-label="Zielgruppen">') "Audience should be a compact band"
Assert-True ($html -match 'class="audience-tag"') "Audience band label should use a styled tag"
Assert-True ($plainText -match "F${ue}r Unternehmen, Konferenzen, Hochschulen, Verb${ae}nde und Organisationen") "Compact audience band text is missing"
Assert-True ($html -notmatch 'class="red-section"' -and $html -notmatch 'class="audience-list"') "Large red audience section should not remain"
Assert-True ($css -match "\.audience-band" -and $css -match "\.audience-band-inner" -and $css -match "\.audience-tag" -and $css -notmatch "\.red-section") "Compact audience band styles are missing"
Assert-True ($html -match "<details" -and $html -match "<summary") "Native expandable FAQ/details are missing"
Assert-True ([regex]::Matches($html, "<script").Count -eq 2 -and $html -notmatch '<script[^>]+src=') "Page should only include local contact enhancement and structured data scripts"
Assert-True ($impressumHtml -match '<html lang="de">' -and $datenschutzHtml -match '<html lang="de">') "Legal pages should use German document language"
Assert-True ($impressumHtml -match '<meta charset="utf-8">' -and $datenschutzHtml -match '<meta charset="utf-8">') "Legal pages should use UTF-8"
Assert-True ($impressumText -match "Impressum" -and $impressumText -match "Andrei Chiriches" -and $impressumText -match "Passau" -and $impressumText -match "contact@andrei-chiriches\.com") "Impressum content is incomplete"
Assert-True ($datenschutzText -match "Datenschutz" -and $datenschutzText -match "Andrei Chiriches" -and $datenschutzText -match "contact@andrei-chiriches\.com" -and $datenschutzText -match "Keine Cookies" -and $datenschutzText -match "Keine Analyse") "Privacy content is incomplete"
Assert-True ($datenschutzText -match "Kontaktformular" -and $datenschutzText -match "Web3Forms" -and $datenschutzText -match "Name, E-Mail-Adresse, Organisation und Nachricht" -and $datenschutzText -match "erst beim Absenden des Formulars") "Privacy policy should describe the Web3Forms contact form"
Assert-True ($datenschutzText -notmatch "kein Kontaktformular") "Privacy policy should not claim there is no contact form"
Assert-True ($impressumHtml -notmatch "<script" -and $datenschutzHtml -notmatch "<script") "Legal pages should not include JavaScript"
Assert-True ($css -match "\.legal-page" -and $css -match "\.legal-content" -and $css -match "\.legal-nav") "Legal page styles are missing"
Assert-True ($contactSvg -match "KI Netzwerk" -and $contactSvg -match "data-small-node-network") "Contact graphic should use a small connected-dot network motif"
Assert-True ($contactSvg -notmatch 'd="M354 96h278') "Old contact bar graphic should not be used"
Assert-True ($contactSvg -notmatch 'stroke-width="1[0-9]|stroke-width="2[0-9]|r="1[0-9]|r="2[0-9]|r="3[0-9]') "Contact graphic should use small dots and thin lines"
Assert-True ($topicsSvg -match "Teilhabenetze" -and $topicsSvg -match "data-small-node-network") "Topics graphic should use a small connected-dot network motif"
Assert-True ($topicsSvg -match "#CF1C18" -and $topicsSvg -match "#FBFBFB" -and $topicsSvg -match "#0A0A0A") "Topics graphic should keep the brand palette"
Assert-True ($topicsSvg -notmatch 'd="M127 157h507') "Old topics bar graphic should not be used"
Assert-True ($topicsSvg -notmatch 'stroke-width="1[0-9]|stroke-width="2[0-9]|r="1[0-9]|r="2[0-9]|r="3[0-9]') "Topics graphic should use small dots and thin lines"

Assert-True ($assetFiles.Count -ge 3) "Expected at least three static visual assets"
Assert-True ($css -match "#CF1C18" -and $css -match "#0A0A0A" -and $css -match "#FBFBFB") "Core palette is missing"
Assert-True ($css -match "--max: 1120px") "Desktop content width should be compact"
Assert-True ($css -match "max-width: var\(--max\)") "Wide screens should not stretch the layout"
Assert-True ($css -match "@media \(max-width: 900px\)" -and $css -match "@media \(max-width: 560px\)") "Responsive breakpoints are missing"
Assert-True ($css -match "overflow-x: hidden") "Horizontal overflow guard is missing"
Assert-True ($css -match ":hover") "Button/link hover states are missing"
Assert-True ($css -notmatch "@keyframes|animation:|transition:[^;]*(opacity|transform|all)") "Only simple hover effects should be used"

Write-Host "Static site checks passed."
