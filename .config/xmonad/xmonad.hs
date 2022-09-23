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
                         , focusedBorderColor = cyan
                         , startupHook        = myStartupHook
                         , handleEventHook    = handleEventHook def
                         }

editor = "emacsclient -c -a ''"
browser = "firefox"
screenLocker = "slock"
dmenu script = concat ["dmm ~/.config/xmonad/", script, ".toml"]
wsKeys = [xK_1 .. xK_9] ++ [xK_grave]
myWorkspaces = ["web", "dev", "doc", "steam", "5", "6", "7", "8", "9", "0"]
myStartupHook = spawn "~/.config/xmonad/startup.fish"

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
  tall = renamed [Replace "tall"] $ magnifierOff $ Tall 1 (1 / 12) (1 / 2)
  center =
    renamed [Replace "center"] $ magnifierOff $ ThreeColMid 1 (1 / 12) (1 / 2)
  grid = renamed [Replace "grid"] $ magnifiercz (5 / 3) $ Grid (3 / 2)
  full = renamed [Replace "full"] Full

myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig { XMonad.modMask = modMask }) =
  M.fromList
    $  [ ((m, xK_z)      , refresh)
       , ((m_s, xK_q)    , spawn softRestart)
       , ((m_c_s, xK_q)  , io exitSuccess)
       ,
      -- Common Programs
         ((m, xK_t)      , spawn $ XMonad.terminal conf)
       , ((m_s, xK_z)    , spawn screenLocker)
       , ((m, xK_e)      , spawn editor)
       , ((m, xK_b)      , spawn browser)
       , ((m, xK_q)      , spawn $ dmenu "system")
       , ((m_s, xK_r)    , spawn $ dmenu "common")
       , ((m, xK_r)      , spawn $ dmenu "run")
       ,
      -- Window Control
         ((m, xK_m)      , windows W.focusMaster)
       , ((m, xK_j)      , windows W.focusDown)
       , ((m, xK_k)      , windows W.focusUp)
       , ((m_s, xK_m)    , windows W.swapMaster)
       , ((m_s, xK_j)    , windows W.swapDown)
       , ((m_s, xK_k)    , windows W.swapUp)
       , ((m_s, xK_c)    , kill)
       , ((m_c_s, xK_c)  , killAll)
       ,
      -- Layout Control
         ((m, xK_Tab)    , sendMessage NextLayout)
       , ((m_s, xK_h)    , sendMessage Shrink)
       , ((m_s, xK_l)    , sendMessage Expand)
       , ((m_c, xK_h)    , sendMessage $ IncMasterN 1)
       , ((m_c, xK_l)    , sendMessage $ IncMasterN (-1))
       , ((m_s, xK_space), sendMessage Magnifier.Toggle)
       , ((m, xK_space)  , sendMessage ToggleStruts)
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
      else W.float w (W.RationalRect (1 / 6) (1 / 6) (2 / 3) (2 / 3)) s
    )

-- purity colors
black = base0
red = "#ff0040"
green = "#40ff00"
yellow = "#ffc000"
blue = "#0040ff"
magenta = "#c000ff"
cyan = "#00c0ff"
white = base6

brightBlack = base2
brightRed = "#ff4000"
brightGreen = "#00ff40"
brightYellow = "#c0ff00"
brightBlue = "#4000ff"
brightMagenta = "#ff00c0"
brightCyan = "#00ffc0"
brightWhite = base8

base0 = "#000000"
base1 = "#101010"
base2 = "#202020"
base3 = "#404040"
base4 = "#808080"
base5 = "#c0c0c0"
base6 = "#e0e0e0"
base7 = "#f0f0f0"
base8 = "#ffffff"

bg = base1
fg = base7
grey = base4
