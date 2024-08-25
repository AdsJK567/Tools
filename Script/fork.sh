#!/bin/bash

# 创建规则目录
mkdir -p Tools/Ruleset/mihomo/{geosite,geoip}


#!/bin/bash

#!date = 2024-08-25 15:55
# 创建规则目录
mkdir -p Tools/Ruleset/mihomo/{geosite,geoip}

#--- mihomo list ---#
# Apple
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Apple.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/apple.list"

# ChatGPT
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Openai.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/openai.list"

# Chat
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Facebook.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/facebook.list"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Instagram.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/instagram.list"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Twitter.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/twitter.list"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/telegram.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/telegram.list"
# Chat ip
curl -L -o Tools-repo/Ruleset/mihomo/geoip/telegram.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/telegram.list"
curl -L -o Tools-repo/Ruleset/mihomo/geoip/Facebook.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/facebook.list"
curl -L -o Tools-repo/Ruleset/mihomo/geoip/Twitter.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/twitter.list"

# China
curl -L -o Tools-repo/Ruleset/mihomo/geosite/China.list  "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/cn.list"
# China ip
curl -L -o Tools-repo/Ruleset/mihomo/geoip/China.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/cn.list"

# Global
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Global.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/geolocation-!cn.list"

# Google
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Google.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/google.list"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/YouTube.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/youtube.list"
# Google ip
curl -L -o Tools-repo/Ruleset/mihomo/geoip/Google.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/google.list"

# Game
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Steam.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/steam.list"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Epic.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/epicgames.list"

# Media
curl -L -o Tools-repo/Ruleset/mihomo/geosite/tiktok.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/tiktok.list"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Bilibili.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/bilibili.list"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Disney.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/disney.list"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Netflix.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/netflix.list"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Spotify.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/spotify.list"
# Media ip
curl -L -o Tools-repo/Ruleset/mihomo/geoip/Netflix.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/netflix.list"

# Microsoft
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Line.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/line.list"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/GitHub.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/github.list"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/OneDrive.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/onedrive.list"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Microsoft.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/microsoft.list"

# PayPal
curl -L -o Tools-repo/Ruleset/mihomo//PayPal.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/paypal.list"


# Local
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Local.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/private.list"
# Local ip
curl -L -o Tools-repo/Ruleset/mihomo/geoip/Local.list "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/private.list"


#--- mihomo mrs ---#
# Apple
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Apple.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/apple.mrs"

# ChatGPT
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Openai.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/openai.mrs"

# Chat
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Facebook.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/facebook.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Instagram.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/instagram.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Twitter.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/twitter.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/telegram.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/telegram.mrs"
# Chat ip
curl -L -o Tools-repo/Ruleset/mihomo/geoip/telegram.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/telegram.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geoip/Facebook.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/facebook.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geoip/Twitter.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/twitter.mrs"

# China
curl -L -o Tools-repo/Ruleset/mihomo/geosite/China.mrs  "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/cn.mrs"
# China ip
curl -L -o Tools-repo/Ruleset/mihomo/geoip/China.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/cn.mrs"

# Global
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Global.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/geolocation-!cn.mrs"

# Google
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Google.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/google.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/YouTube.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/youtube.mrs"
# Google ip
curl -L -o Tools-repo/Ruleset/mihomo/geoip/Google.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/google.mrs"

# Game
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Steam.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/steam.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Epic.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/epicgames.mrs"

# Media
curl -L -o Tools-repo/Ruleset/mihomo/geosite/tiktok.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/tiktok.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Bilibili.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/bilibili.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Disney.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/disney.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Netflix.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/netflix.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Spotify.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/spotify.mrs"
# Media ip
curl -L -o Tools-repo/Ruleset/mihomo/geoip/Netflix.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/netflix.mrs"

# Microsoft
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Line.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/line.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/GitHub.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/github.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/OneDrive.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/onedrive.mrs"
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Microsoft.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/microsoft.mrs"

# PayPal
curl -L -o Tools-repo/Ruleset/mihomo/geosite/PayPal.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/paypal.mrs"


# Local
curl -L -o Tools-repo/Ruleset/mihomo/geosite/Local.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/private.mrs"
# Local ip
curl -L -o Tools-repo/Ruleset/mihomo/geoip/Local.mrs "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/private.mrs"
