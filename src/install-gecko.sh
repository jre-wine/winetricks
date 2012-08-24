#!/bin/sh
# Install the Gecko and Mono needed by modern wines
set -e
set -x

# Wine installs to /usr/local by default:
if test -d /usr/local/share/wine
then
    WINE_SHARE_PREFIX=/usr/local/share/wine
else
    WINE_SHARE_PREFIX=/usr/share/wine
fi

install_gecko()
{
    case $1 in
    wine-1.1.2[789]*|wine-1.1.[34]*|wine-1.2*|wine-1.3|wine-1.3.[01]|wine-1.3.[0]-*)
        GECKO_VERSION=1.0.0
        GECKO_SHA1SUM=afa22c52bca4ca77dcb9edb3c9936eb23793de01
        GECKO_SUFFIX=.cab
        ;;
    gecko-1.2)
        GECKO_VERSION=1.2.0
        GECKO_SHA1SUM=6964d1877668ab7da07a60f6dcf23fb0e261a808
        GECKO_SUFFIX=.msi
        ;;
    gecko-1.3)
        GECKO_VERSION=1.3
        case $myarch in
        x86)   GECKO_SHA1SUM=acc6a5bc15ebb3574e00f8ef4f23912239658b41 ;;
        x86_64) GECKO_SHA1SUM=5bcf29c48677dffa7a9112d481f7f5474cd255d4 ;;
        esac
        GECKO_SUFFIX=.msi
        ;;
    gecko-1.4)
        GECKO_VERSION=1.4
        case $myarch in
        x86)   GECKO_SHA1SUM=c30aa99621e98336eb4b7e2074118b8af8ea2ad5 ;;
        x86_64) GECKO_SHA1SUM=bf0aaf56a8cf9abd75be02b56b05e5c4e9a4df93 ;;
        esac
        GECKO_SUFFIX=.msi
        ;;
    gecko-1.5)
        GECKO_VERSION=1.5
        case $myarch in
        x86)   GECKO_SHA1SUM=07b2bc74d03c885bb39124a7641715314cd3ae71 ;;
        x86_64) GECKO_SHA1SUM=80a3b36c30bb79a11889879392fdc1fcda9ca165 ;;
        esac
        GECKO_SUFFIX=.msi
        ;;
    gecko-1.6)
        GECKO_VERSION=1.6
        case $myarch in
        x86)   GECKO_SHA1SUM=41167632dbc30f32dce7dca43c2a0487aa7cac04 ;;
        x86_64) GECKO_SHA1SUM=edc626480024f58e294447573c7ab94606e8d610 ;;
        esac
        GECKO_SUFFIX=.msi
        ;;
    gecko-1.7)
        GECKO_VERSION=1.7
        case $myarch in
        x86)   GECKO_SHA1SUM=efebc4ed7a86708e2dc8581033a3c5d6effe0b0b ;;
        x86_64) GECKO_SHA1SUM=2253e7ce3a699ddd110c6c9ce4c7ca7e6f7c02f5 ;;
        esac
        GECKO_SUFFIX=.msi
        ;;
    *)
        GECKO_VERSION=1.1.0
        GECKO_SHA1SUM=1b6c637207b6f032ae8a52841db9659433482714
        GECKO_SUFFIX=.cab
        ;;
    esac

    if test ! -f $WINE_SHARE_PREFIX/gecko/wine_gecko-$GECKO_VERSION-$myarch$GECKO_SUFFIX
    then
        rm -f wine_gecko-$GECKO_VERSION-$myarch$GECKO_SUFFIX
        wget http://downloads.sourceforge.net/wine/wine_gecko-$GECKO_VERSION-$myarch$GECKO_SUFFIX

        gotsum=`sha1sum < wine_gecko-$GECKO_VERSION-$myarch$GECKO_SUFFIX | sed 's/(stdin)= //;s/ .*//'`
        if [ "$gotsum"x != "$GECKO_SHA1SUM"x ]
        then
           echo "sha1sum mismatch!  Please try again."
           exit 1
        fi

        sudo mkdir -p $WINE_SHARE_PREFIX/gecko
        sudo mv wine_gecko-$GECKO_VERSION-$myarch$GECKO_SUFFIX $WINE_SHARE_PREFIX/gecko/
    fi
}

install_mono()
{
    case $1 in
    0.0.4) MONO_SHA1SUM=7d827f7d28a88ae0da95a136573783124ffce4b1;;
    *) return;;
    esac

    if test ! -f $WINE_SHARE_PREFIX/mono/wine-mono-$1.msi
    then
        rm -f wine-mono-$1.msi
        wget http://downloads.sourceforge.net/wine/wine-mono-$1.msi

        gotsum=`sha1sum < wine-mono-$1.msi | sed 's/(stdin)= //;s/ .*//'`
        if [ "$gotsum"x != "$MONO_SHA1SUM"x ]
        then
           echo "sha1sum mismatch!  Please try again."
           exit 1
        fi

        sudo mkdir -p $WINE_SHARE_PREFIX/mono
        sudo mv wine-mono-$1.msi $WINE_SHARE_PREFIX/mono
    fi
}

# Install gecko for stable wine and the current dev branch
myarch=x86
install_gecko gecko-1.7
install_gecko gecko-1.6
install_gecko gecko-1.5
install_gecko gecko-1.4
install_gecko gecko-1.3
install_gecko wine-1.2
install_gecko wine-1.3.3
install_gecko gecko-1.2
case `arch` in
amd64|x86_64)
    myarch=x86_64
    install_gecko gecko-1.7
    install_gecko gecko-1.6
    install_gecko gecko-1.5
    install_gecko gecko-1.4
    install_gecko gecko-1.3
    ;;
esac

# And mono, too
install_mono 0.0.4
