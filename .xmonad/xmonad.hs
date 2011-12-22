import System.IO
import XMonad
import Data.Ratio ((%))
import XMonad.Hooks.DynamicLog
    hiding (pprWindowSet)
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.Grid
import XMonad.Layout.IM
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Reflect
import XMonad.Layout.ShowWName
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig
import XMonad.Util.Loggers
import XMonad.Util.Run(spawnPipe)
import XMonad.Actions.UpdatePointer

--sets behaviour for certain windows:
--doFloat causes window to launch in float mode
--doIgnore prevents xmonad from managin the window at all
--W.shift sends the window to the specified
--workspace, which must be defined in workspaces variable (line 102)

myManageHook = composeAll
      [ className =? "Gimp"                                  --> doFloat
      , className =? "Kcalc"                                 --> doFloat
      , resource  =? "desktop_window"                        --> doIgnore
      , className =? "Pidgin"                                --> doF (W.shift "social")
      , className =? "Skype"                                 --> doF (W.shift "social")
      , className =? "Xchat"                                 --> doF (W.shift "social")
      , className =? "Firefox"                               --> doF (W.shift "web")
      , className =? "Chromium-browser"                      --> doF (W.shift "web")
      , className =? "Eclipse"                               --> doF (W.shift "dev")
      , className =? "VLC"                                   --> doF (W.shift "media")
      , className =? "conky"                                 --> doF (W.shift "conky")
      , className =? "sonata"                                --> doF (W.shift "misc")
      , className =? "VirtualBox"                            --> doF (W.shift "vm")
      , title     =? "Bullets and Numbering"                 --> doF W.focusDown
      , title     =? "Table"                                 --> doF W.focusDown
        ]

--used to format the bitmaps, see line 86
wrapBitmap bitmap = "^p(5)^i(" ++ myBitmapsPath ++ bitmap ++ ")^p(5)"
--location of bitmaps
myBitmapsPath = "/home/thor/.xmonad/bitmaps/"
imLayout = withIM pidginRatio pidginRoster $
               reflectHoriz $
               withIM skypeRatio skypeRoster
               (Grid)
               where
                       pidginRatio = (1%7)
                       skypeRatio = (1%6)
                       pidginRoster = And (ClassName "Pidgin") (Role "buddy_list")
                       skypeRoster = (ClassName "Skype") `And` (Not (Title "Options")) `And` (Not (Role "Chats")) `And` (Not (Role "CallWindowForm"))



main = do
    --spawns dzen2 aligned at top of 1280x1024 monitor (my left monitor).
    h <- spawnPipe "dzen2 -xs 1 -ta l -w 1920 -h 17 -fg '#dddddd' -bg '#000000' -e ''"
    --spawns trayer on top of dzen2, just to the left of my clock.
    --margin option is from the right, so it is large due to the 1600x900 monitor
    spawn "killall trayer"
    spawn "sleep 5 && trayer --edge top --align right --SetDockType true --SetPartialStrut true  --expand true --widthtype pixel --width 128 --margin 1921 --transparent true --alpha 0 --tint 0x000000 --height 17"
    --simply starts these programs by running the commands
    --spawn "sleep 10 && ~/conky-git/build/src/conky"
    spawn "pidgin"
    --spawn "skype"
    spawn "chromium"
    -- spawn "sleep 10 && wpa-gui -t"
    -- spawn "VBoxHeadless -startvm \"Ubuntu Server\""
    spawn "mpd"
    --making an urgency hook (even with just NoUrgencyHook) allows programs
    --that can set wm_status to urgent to cause the workspace name to reflect
    --that status (see line 99)
    xmonad $ withUrgencyHook NoUrgencyHook $ defaultConfig{
        --focus follows mouse location, no click or keyboard interaction required
        --to change windows.
        focusFollowsMouse = True,
        --manageDocks causes xmonad to ignore dzen and trayer, so they
        --do not get tiled.
        manageHook = manageDocks <+> myManageHook <+> manageHook defaultConfig
        --avoidStruts makes xmonad rezpect dzen2's space, so there is no
        --overlap
        , layoutHook = avoidStruts $ onWorkspace "social" imLayout $ layoutHook defaultConfig
        --sets the dzen2 workspace label properties (on the bar only)
        , logHook = (dynamicLogWithPP $ dzenPP
        --Visible workspace (with two monitors, the one that is not active)
        --is white text, dark grey background
        { ppVisible = dzenColor "white" "gray40" . pad
        --active workspace has white text and lighter gray background
        , ppCurrent = dzenColor "white" "gray60" . pad
        --hidden workspaces with windows open have white text and black background
        , ppHidden = dzenColor "white" "black" . pad
        --hidden workspaces with no windows are simply gray text on black
        , ppHiddenNoWindows = dzenColor "grey60" "black" . pad
        --if a program on an inactive workspace sets the urgent flag, that workspace's
        --name will appear in red until it recieves focus
        , ppUrgent = dzenColor "red" "" . dzenStrip
        --formats the name of the active window in the dzen2 bar
        , ppTitle = wrap " [" "]" . shorten 100
        --makes the tiling mode a nice tiny image as opposed to "tall", "float", etc
        , ppLayout = dzenColor "grey" "" .
                (\x -> case x of
                    "Tall" -> wrapBitmap "rob/tall.xbm"
                    "Mirror Tall" -> wrapBitmap "rob/mtall.xbm"
                    "Full" -> wrapBitmap "rob/full.xbm"
                    )
        --right aligned clock on the dzen bar
        , ppExtras = [ date "^pa(1154)%a %b %d %H:%M"]
        --outputs info to h, which we defined in line 44
        , ppOutput = hPutStrLn h
        }) >> updatePointer (Relative 0.5 0.25)
        --rebind mod to the windows/super key
        , modMask = mod4Mask
        --define workspace names, if you do not have 9 to name then
        --it will automatically add the rest up to 9, with name "7","8","9", etc
        --there is more flexibility here that I haven't played with
        , workspaces    = ["web","dev","social","school 1","school 2","office","media","misc","vm"]
        --sets additional hotkeys
        } `additionalKeys`
        [ ((mod4Mask .|. shiftMask, xK_l), spawn "slock")
        , ((controlMask, xK_F1), spawn "konsole")
        , ((controlMask, xK_F2), spawn "dolphin")
        , ((controlMask, xK_F3), spawn "chromium")
        , ((controlMask, xK_F4), spawn "ksnapshot")
        , ((controlMask, xK_F5), spawn "kcalc")
        , ((controlMask, xK_Scroll_Lock), spawn "/usr/lib/kde4/libexec/kscreenlocker")
        , ((controlMask, xK_F8), spawn "~/conky -c .conkyrc_xmonad")
        ]
        --sets hotkeys with special names, see API for full list
        `additionalKeysP`
        [ ("<XF86AudioMute>", spawn "amixer sset Master toggle")
        , ("<XF86AudioRaiseVolume>", spawn "amixer sset Master 2+")
        , ("<XF86AudioLowerVolume>", spawn "amixer sset Master 2-")
        , ("<XF86AudioPlay>", spawn "mpc toggle")
        , ("<XF86AudioStop>", spawn "mpc stop")
        , ("<XF86AudioNext>", spawn "mpc next")
        , ("<XF86AudioPrev>", spawn "mpc prev")
        ]

