import qualified Data.Map                      as M
import           System.Exit
import           XMonad
import           XMonad.Actions.WithAll
import           XMonad.Config.Desktop
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.EwmhDesktops
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.ManageHelpers
import           XMonad.Hooks.TaffybarPagerHints
import           XMonad.Hooks.UrgencyHook
import           XMonad.Layout.GridVariants
import           XMonad.Layout.Magnifier
import qualified XMonad.Layout.Magnifier       as Magnifier
import qualified XMonad.Layout.MultiToggle     as MT
import           XMonad.Layout.NoBorders
import           XMonad.Layout.PerWorkspace
import           XMonad.Layout.Renamed
import           XMonad.Layout.ThreeColumns
import           XMonad.Layout.ToggleLayouts
import qualified XMonad.Layout.ToggleLayouts   as T
import qualified XMonad.StackSet               as W
import           XMonad.Util.Cursor
import           XMonad.Util.WorkspaceCompare


main =
    xmonad
        $ docks
        . setEwmhActivateHook doAskUrgent
        . ewmh
        . pagerHints
        $ myConfig

myConfig = desktopConfig { terminal           = "alacritty"
                         , modMask            = mod4Mask
                         , focusFollowsMouse  = True
                         , workspaces         = myWorkspaces
                         , keys               = myKeys
                         , manageHook         = myManageHook
                         , layoutHook         = myLayoutHook
                         , borderWidth        = 1
                         , normalBorderColor  = black
                         , focusedBorderColor = blue
                         , startupHook        = myStartupHook
                         , handleEventHook    = handleEventHook def
                         }

editor = "emacsclient -c -a ''"
browser = "firefox"
screenLocker = "slock"
dmenu script = concat ["dmenu-manager ~/.config/xmonad/", script, ".toml"]
dmenuRun = concat
    [ "dmenu_run -i -p 'run:' "
    , "-fn 'Hack Nerd Font:size=16' "
    , "-nb '"
    , dark3 -- normal background
    , "' -nf '"
    , light0 -- normal foreground
    , "' -sb '"
    , blue -- selected background
    , "' -sf '"
    , dark3 -- selected foreground
    , "'"
    ]

wsKeys = [xK_1 .. xK_9] ++ [xK_grave]
myWorkspaces = ["web", "dev", "doc", "steam", "5", "6", "7", "8", "9", "0"]

myStartupHook = do
    spawn "xsetroot -cursor_name left_ptr"
    spawn "~/.fehbg"
    spawn "pkill taffybar; taffybar"

myManageHook = custom <+> manageHook desktopConfig
  where
    custom = composeAll
        [ className =? "Tor Browser" --> doFloat
        , className =? "Steam" --> doShift "steam"
        , isDialog --> doFloat
        ]

myLayoutHook =
    avoidStruts
        $   smartBorders
        $   toggleLayouts full
        $   onWorkspace "0" grid
        $   tall
        ||| center
        ||| grid
  where
    tall   = renamed [Replace "tall"] $ magnifierOff $ Tall 1 (1 / 12) (1 / 2)
    center = renamed [Replace "center"] $ magnifierOff $ ThreeColMid
        1
        (1 / 12)
        (1 / 2)
    grid = renamed [Replace "grid"] $ magnifiercz (5 / 3) $ Grid (3 / 2)
    full = renamed [Replace "full"] $ Full

myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig { XMonad.modMask = modMask }) =
    M.fromList
        $  [ ((m, xK_z)      , refresh)
           , ((m_s, xK_q)    , spawn softRestart)
           , ((m_c_s, xK_q)  , io exitSuccess)
           -- Common Programs
           , ((m, xK_t)      , spawn $ XMonad.terminal conf)
           , ((m_s, xK_z)    , spawn screenLocker)
           , ((m, xK_e)      , spawn editor)
           , ((m, xK_b)      , spawn browser)
           , ((m, xK_q)      , spawn $ dmenu "system")
           , ((m_s, xK_r)    , spawn $ dmenu "common")
           , ((m, xK_r)      , spawn dmenuRun)
           -- Window Control
           , ((m, xK_m)      , windows W.focusMaster)
           , ((m, xK_j)      , windows W.focusDown)
           , ((m, xK_k)      , windows W.focusUp)
           , ((m_s, xK_m)    , windows W.swapMaster)
           , ((m_s, xK_j)    , windows W.swapDown)
           , ((m_s, xK_k)    , windows W.swapUp)
           , ((m_s, xK_c)    , kill)
           , ((m_c_s, xK_c)  , killAll)
           -- Layout Control
           , ((m, xK_Tab)    , sendMessage NextLayout)
           , ((m_s, xK_h)    , sendMessage Shrink)
           , ((m_s, xK_l)    , sendMessage Expand)
           , ((m_c, xK_h)    , sendMessage $ IncMasterN 1)
           , ((m_c, xK_l)    , sendMessage $ IncMasterN (-1))
           , ((m, xK_space)  , sendMessage Magnifier.Toggle)
           , ((m_s, xK_space), sendMessage ToggleStruts)
           , ((m, xK_f)      , toggleFullscreen)
           , ((m_s, xK_f)    , withFocused toggleFloat)
           , ((m_c_s, xK_f)  , sinkAll)
           ]
        ++
           -- Workspaces
           [ ((m .|. msk, k), windows $ f i)
           | (i, k  ) <- zip (XMonad.workspaces conf) wsKeys
           , (f, msk) <- [(W.greedyView, 0), (W.shift, s)]
           ]
  where
    m                = modMask
    s                = shiftMask
    c                = controlMask
    m_s              = m .|. s
    m_c              = m .|. c
    m_c_s            = m_c .|. s
    softRestart      = "xmonad --recompile; xmonad --restart"
    toggleFullscreen = sendMessage ToggleLayout >> sendMessage ToggleStruts
    toggleFloat w = windows
        (\s -> if M.member w (W.floating s)
            then W.sink w s
            else (W.float w (W.RationalRect (1 / 6) (1 / 6) (2 / 3) (2 / 3)) s)
        )

-- Solarized Colors
black = dark3
white = light3
yellow = "#b58900"
orange = "#cb4b16"
red = "#dc322f"
magenta = "#d33682"
violet = "#6c71c4"
blue = "#268bd2"
cyan = "#2aa198"
green = "#859900"

dark3 = "#002b36"
dark2 = "#073642"
dark1 = "#586e75"
dark0 = "#657b83"
light0 = "#839496"
light1 = "#93a1a1"
light2 = "#eee8d5"
light3 = "#fdf6e3"
