import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Config.Desktop
import System.Exit (exitSuccess)
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WithAll (sinkAll, killAll)
import XMonad.Hooks.ManageDocks (ToggleStruts(..))
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR))
import XMonad.Layout.Renamed
import XMonad.Layout.ResizableTile
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.NoBorders (smartBorders)
import XMonad.Layout.PerWorkspace (onWorkspace)

import qualified Data.Map as M
import qualified XMonad.StackSet as W
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))


main = xmonad =<< statusBar "xmobar" myPP toggleStrutsKey myConfig


myConfig = desktopConfig
    { terminal = myTerminal
    , modMask = mod4Mask
    , focusFollowsMouse = True
    , workspaces = myWorkspaces
    , keys = myKeys
    , manageHook = myManageHook
    , layoutHook = myLayoutHook
    , borderWidth = 2
    , normalBorderColor = brBlack
    , focusedBorderColor = blue
    , startupHook = do
        windows $ W.greedyView startupWorkspace
        spawn "~/.xmonad/startup.sh"
    }


myFont = "xft:Noto Sans:size=11:antialias=true:hinting=true"

myTerminal = "alacritty"

myBrowser = "firefox"

myScreenLocker = "slock"

startupWorkspace = "1"

myWorkspaces =
    [ "bg"
    , "1"
    , "2"
    , "3"
    , "4"
    , "5"
    , "6"
    , "7"
    , "8"
    , "9"
    ]

wsHidden = ["bg"]

wsKeys = [xK_grave] ++ [xK_1..xK_9]

myManageHook = custom <+> manageHook desktopConfig
    where custom = composeAll [className =? "Tor Browser" --> doFloat]

myLayoutHook =
    onWorkspace "bg" grid
    $ mkToggle (NBFULL ?? EOT)
    $ mkToggle (MIRROR ?? EOT)
    $ tall
    ||| grid

tall =
    renamed [Replace "tall"]
    $ smartBorders
    $ magnifierOff
    $ ResizableTall 1 (3/100) (1/2) []
grid =
    renamed [Replace "grid"]
    $ smartBorders
    $ magnifierOff
    $ Grid (16/10)

myPP = xmobarPP
    { ppCurrent =
        xmobarColor white black
        . wrap "  " "  "
    , ppHidden = replace wsHidden ""
    , ppHiddenNoWindows = (\x -> "")
    , ppTitle =
        color green
        . truncate 120
        . (++) "    "
    , ppSep = "    |    "
    , ppWsSep = "   "
    , ppUrgent = color red . wrap "!" "!"
    } where
    replace x y z
        | z `elem` x = y
        | otherwise = z
    truncate max str
        | length str > max = take max str ++ " ..."
        | otherwise = str
    color fg = xmobarColor fg ""


toggleStrutsKey XConfig {XMonad.modMask = m} = (m, xK_s)

myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
-- Xmonad
    [ ((m, xK_q), spawn "xmonad --recompile; xmonad --restart")
    , ((m_s, xK_q), io exitSuccess)
-- Run Prompt
    , ((m, xK_p), spawn "dmenu_run -i -p \"Run: \"")
-- Useful Programs
    , ((m, xK_Return), spawn $ XMonad.terminal conf)
    , ((m, xK_b), spawn myBrowser)
    , ((m_s, xK_b), spawn "vlc ~/music/")
-- Kill Windows
    , ((m_s, xK_c), kill)
    , ((m_c_s, xK_c), killAll)
-- Floating Windows
    , ((m, xK_f), withFocused float)
    , ((m_s, xK_f), withFocused $ windows . W.sink)
    , ((m_c_s, xK_f), sinkAll)
-- Window Navigation
    , ((m, xK_m), windows W.focusMaster)
    , ((m, xK_j), windows W.focusDown)
    , ((m, xK_k), windows W.focusUp)
    , ((m_s, xK_m), windows W.swapMaster)
    , ((m_s, xK_j), windows W.swapDown)
    , ((m_s, xK_k), windows W.swapUp)
    , ((m_c_s, xK_m), promote)
    , ((m_s, xK_Tab), rotSlavesDown)
    , ((m_c, xK_Tab), rotAllDown)
-- Layout Control
    , ((m, xK_Tab ), sendMessage NextLayout)
    , ((m_s, xK_space), sendMessage (Toggle)) -- toggle magnifier
    , ((m_c, xK_space), sendMessage $ MT.Toggle MIRROR)
    , ((m, xK_space), sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts)
-- Resize Windows
    , ((m_s, xK_h), sendMessage Shrink)
    , ((m_s, xK_l), sendMessage Expand)
-- Change Master Pane Capacity
    , ((m, xK_comma ), sendMessage (IncMasterN 1))
    , ((m, xK_period), sendMessage (IncMasterN (-1)))
-- Lock Screen
    , ((m_s, xK_z), spawn myScreenLocker)
-- Etc
    , ((m, xK_n), refresh)
    ] ++
-- Workspaces
    [ ((m .|. msk, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) wsKeys,
            (f, msk) <- [(W.greedyView, 0), (W.shift, s)]
    ] where
        m = modMask
        s = shiftMask
        c = controlMask
        m_s = m .|. s
        m_c = m .|. c
        m_c_s = m_c .|. s


-- Solarized Colors
black = "#073642"
white = "#eee8d5"
red = "#dc322f"
yellow = "#b58900"
green = "#859900"
cyan = "#2aa198"
blue = "#268bd2"
magenta = "#d33682"
brBlack = "#002b36"
brWhite = "#fdf6e3"
brRed = "#cb4b16"
brYellow = "#657b83"
brGreen = "#586e75"
brCyan = "#93a1a1"
brBlue = "#839496"
brMagenta = "#6c71c4"
