import XMonad
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.EwmhDesktops
import XMonad.Actions.WithAll (killAll, sinkAll)
import XMonad.Config.Desktop
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Layout.ThreeColumns (ThreeCol(ThreeColMid))
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.ToggleLayouts (toggleLayouts, ToggleLayout(ToggleLayout))
import XMonad.Layout.Magnifier (magnifierOff, magnifiercz)
import XMonad.Layout.NoBorders (smartBorders, noBorders)
import XMonad.Layout.PerWorkspace (onWorkspace)
import XMonad.Layout.Renamed (renamed, Rename(Replace))

import System.Exit (exitSuccess)
import System.Taffybar.Support.PagerHints (pagerHints)

import qualified XMonad.Layout.Magnifier as Magnifier
import qualified Data.Map as M
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))
import qualified XMonad.Layout.ToggleLayouts as T
  ( ToggleLayout(Toggle)
  , toggleLayouts
  )
import qualified XMonad.StackSet as W

main = xmonad myConfig

myConfig = docks $ ewmh $ pagerHints
  desktopConfig
    { terminal = "alacritty"
    , modMask = mod4Mask
    , focusFollowsMouse = True
    , workspaces = myWorkspaces
    , keys = myKeys
    , manageHook = myManageHook
    , layoutHook = myLayoutHook
    , borderWidth = 2
    , normalBorderColor = black
    , focusedBorderColor = blue
    , startupHook = myStartupHook
    , handleEventHook = handleEventHook def <+> fullscreenEventHook
    }

emacs = "emacsclient -c -a ''"
browser = "firefox"
screenLocker = "slock"
dmenuSystem = "dmenu-manager ~/.config/xmonad/system.toml"
dmenuCommon = "dmenu-manager ~/.config/xmonad/common.toml"
dmenuRun =
  "dmenu_run -i -p 'run: ' " ++
  "-fn 'Hack Nerd Font:size=16' " ++
  "-nb '" ++ base03 ++ "' " ++
  "-nf '" ++ base0 ++ "' " ++
  "-sb '" ++ blue ++ "' " ++
  "-sf '" ++ base03 ++ "'"

wsKeys = [xK_grave] ++ [xK_1 .. xK_9] ++ [xK_0]
myWorkspaces = ["bg", "web", "dev", "doc", "sys", "steam", "6", "7", "8", "9", "0"]
wsHidden = ["bg"]

myStartupHook = do
  windows $ W.greedyView "web"
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
  avoidStruts $
  toggleLayouts
    full $
    onWorkspace "bg" grid $ tall ||| center ||| grid
  where
    tall =
      renamed [Replace "tall"] $
      smartBorders $
      magnifierOff $
      Tall 1 (1 / 12) (1 / 2)
    center =
      renamed [Replace "center"] $
      smartBorders $
      magnifierOff $
      ThreeColMid 1 (1 / 12) (1 / 2)
    grid =
      renamed [Replace "grid"] $
      smartBorders $
      magnifiercz (5 / 3) $
      Grid (3 / 2)
    full =
      renamed [Replace "full"] $
      noBorders $
      Full

myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig {XMonad.modMask = modMask}) =
  M.fromList $
  [ ((m, xK_n), refresh)
  , ((m_s, xK_q), io exitSuccess)
    -- Common Programs
  , ((m, xK_t), spawn $ XMonad.terminal conf)
  , ((m_s, xK_z), spawn screenLocker)
  , ((m, xK_e), spawn emacs)
  , ((m, xK_b), spawn browser)
  , ((m, xK_q), spawn dmenuSystem)
  , ((m_s, xK_r), spawn dmenuCommon)
  , ((m, xK_r), spawn dmenuRun)
    -- Window Control
  , ((m, xK_m), windows W.focusMaster)
  , ((m, xK_j), windows W.focusDown)
  , ((m, xK_k), windows W.focusUp)
  , ((m_s, xK_m), windows W.swapMaster)
  , ((m_s, xK_j), windows W.swapDown)
  , ((m_s, xK_k), windows W.swapUp)
  , ((m_s, xK_c), kill)
  , ((m_c, xK_c), killAll)
    -- Layout Control
  , ((m, xK_Tab), sendMessage NextLayout)
  , ((m, xK_space), sendMessage ToggleLayout >> sendMessage ToggleStruts)
  , ((m_c, xK_space), sendMessage ToggleStruts)
  , ((m_s, xK_space), sendMessage Magnifier.Toggle)
  , ((m_s, xK_h), sendMessage Shrink)
  , ((m_s, xK_l), sendMessage Expand)
  , ((m_c, xK_h), sendMessage $ IncMasterN 1)
  , ((m_c, xK_l), sendMessage $ IncMasterN (-1))
  , ((m, xK_f), withFocused float)
  , ((m_s, xK_f), withFocused $ windows . W.sink)
  , ((m_c, xK_f), sinkAll)
  ] ++
    -- Workspaces
  [ ((m .|. msk, k), windows $ f i)
  | (i, k) <- zip (XMonad.workspaces conf) wsKeys
  , (f, msk) <- [(W.greedyView, 0), (W.shift, s)]
  ]
  where
    m = modMask
    s = shiftMask
    c = controlMask
    m_s = m .|. s
    m_c = m .|. c
    m_c_s = m_c .|. s

-- Solarized Colors
black = base02
white = base2
yellow = "#b58900"
orange = "#cb4b16"
red = "#dc322f"
magenta = "#d33682"
violet = "#6c71c4"
blue = "#268bd2"
cyan = "#2aa198"
green = "#859900"

base03 = "#002b36"
base02 = "#073642"
base01 = "#586e75"
base00 = "#657b83"
base0 = "#839496"
base1 = "#93a1a1"
base2 = "#eee8d5"
base3 = "#fdf6e3"
