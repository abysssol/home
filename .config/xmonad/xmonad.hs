import System.Exit (exitSuccess)
import XMonad
import XMonad.Hooks.ManageHelpers
import XMonad.Actions.WithAll (killAll, sinkAll)
import XMonad.Config.Desktop
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks (ToggleStruts(..))
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (EOT(EOT), (??), mkToggle)
import XMonad.Layout.MultiToggle.Instances (StdTransformers(MIRROR, NBFULL))
import XMonad.Layout.NoBorders (smartBorders)
import XMonad.Layout.PerWorkspace (onWorkspace)
import XMonad.Layout.Renamed
import XMonad.Layout.ResizableTile

import qualified Data.Map as M
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))
import qualified XMonad.Layout.ToggleLayouts as T
  ( ToggleLayout(Toggle)
  , toggleLayouts
  )
import qualified XMonad.StackSet as W

main = xmonad =<< statusBar "xmobar" xmobarConfig toggleStrutsKey myConfig

myConfig =
  desktopConfig
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
    , startupHook = myStartupHook
    }

browser = "firefox"
myTerminal = "alacritty"
screenLocker = "i3lock -ei /usr/share/backgrounds/abyss-locked.png"
dmenuCommon = "dmenu-manager ~/.config/xmonad/common.toml"
dmenuRun =
  "dmenu_run -i " ++
  "-p 'run: ' " ++
  "-fn 'Monoid Nerd Font:11' " ++
  "-nb '" ++ brBlack ++ "' " ++
  "-nf '" ++ brBlue ++ "' " ++
  "-sb '" ++ blue ++ "' " ++
  "-sf '" ++ brBlack ++ "'"

wsKeys = [xK_grave] ++ [xK_1 .. xK_9]
myWorkspaces = ["bg", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
wsHidden = ["bg"]
startupWorkspace = "1"

myStartupHook = do
  windows $ W.greedyView startupWorkspace
  spawn "~/.fehbg"

myManageHook = custom <+> manageHook desktopConfig
  where
    custom = composeAll
      [ className =? "Tor Browser" --> doFloat
      , isDialog --> doFloat
      ]

myLayoutHook =
  onWorkspace "bg" grid $
  smartBorders $
  mkToggle (NBFULL ?? EOT) $
  mkToggle (MIRROR ?? EOT) $
  tall ||| grid
    where
      tall =
        renamed [Replace "tall"] $
        magnifierOff $
        ResizableTall 1 (1 / 12) (1 / 2) []
      grid =
        renamed [Replace "grid"] $
        magnifierOff $
        Grid (3 / 2)

xmobarConfig =
  xmobarPP
    { ppCurrent = xmobarColor white black . wrap "  " "  "
    , ppHidden = replace wsHidden ""
    , ppHiddenNoWindows = (\x -> "")
    , ppTitle = color green . truncate 90 . (++) "  "
    , ppSep = "  |  "
    , ppWsSep = "   "
    , ppUrgent = color red . wrap "!" "!"
    }
  where
    replace x y z
      | z `elem` x = y
      | otherwise = z
    truncate max str
      | length str > max = take max str ++ " ..."
      | otherwise = str
    color fg = xmobarColor fg ""


toggleStrutsKey XConfig {XMonad.modMask = m} = (m, xK_s)

myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig {XMonad.modMask = modMask}) =
  M.fromList $
  [ ((m, xK_n), refresh)
  , ((m_s, xK_q), io exitSuccess)
    -- Common Programs
  , ((m, xK_q), spawn "xmonad --recompile; xmonad --restart")
  , ((m, xK_b), spawn browser)
  , ((m, xK_Return), spawn $ XMonad.terminal conf)
  , ((m_s, xK_z), spawn screenLocker)
  , ((m_s, xK_b), spawn dmenuCommon)
  , ((m, xK_p), spawn dmenuRun)
    -- Window Control
  , ((m, xK_m), windows W.focusMaster)
  , ((m, xK_j), windows W.focusDown)
  , ((m, xK_k), windows W.focusUp)
  , ((m_s, xK_m), windows W.swapMaster)
  , ((m_s, xK_j), windows W.swapDown)
  , ((m_s, xK_k), windows W.swapUp)
  , ((m_s, xK_h), sendMessage Shrink)
  , ((m_s, xK_l), sendMessage Expand)
  , ((m_s, xK_c), kill)
  , ((m_c_s, xK_c), killAll)
    -- Layout Control
  , ((m, xK_Tab), sendMessage NextLayout)
  , ((m_s, xK_space), sendMessage (Toggle)) -- toggle magnifier
  , ((m_c, xK_space), sendMessage $ MT.Toggle MIRROR)
  , ((m, xK_space), sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts)
  , ((m, xK_comma), sendMessage (IncMasterN 1))
  , ((m, xK_period), sendMessage (IncMasterN (-1)))
  , ((m, xK_f), withFocused float)
  , ((m_s, xK_f), withFocused $ windows . W.sink)
  , ((m_c_s, xK_f), sinkAll)
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
