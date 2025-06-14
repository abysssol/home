import Data.Map qualified as M
import System.Exit
import XMonad
import XMonad.Actions.SpawnOn
import XMonad.Actions.WithAll
import XMonad.Config.Desktop
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.TaffybarPagerHints
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.GridVariants
import XMonad.Layout.Magnifier
import XMonad.Layout.Magnifier qualified as Magnifier
import XMonad.Layout.MultiToggle qualified as MT
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Renamed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.ToggleLayouts
import XMonad.Layout.ToggleLayouts qualified as T
import XMonad.StackSet qualified as W
import XMonad.Util.Cursor
import XMonad.Util.SessionStart
import XMonad.Util.WorkspaceCompare

main =
  xmonad
    $ docks
      . setEwmhActivateHook doAskUrgent
      . ewmh
      . pagerHints
    $ myConfig

myConfig =
  desktopConfig
    { terminal = myTerminal,
      modMask = mod4Mask,
      focusFollowsMouse = True,
      workspaces = myWorkspaces,
      keys = myKeys,
      manageHook = myManageHook,
      layoutHook = myLayoutHook,
      borderWidth = 1,
      normalBorderColor = black,
      focusedBorderColor = cyan,
      startupHook = myStartupHook,
      handleEventHook = handleEventHook def
    }

myTerminal = "alacritty"

editor = myTerminal ++ " -e hx"

browser = "librewolf"

screenLocker = "slock"

dmm script = concat ["dmm ~/.config/dmm/", script, ".toml"]

myWorkspaces = ["web", "dev", "doc", "launch", "5", "6", "7", "8", "9", "misc"]

-- mod + wsKey ;; move focus to workspace
-- mod + shift + wsKey ;; move focused window to workspace
wsKeys = [xK_1 .. xK_9] ++ [xK_0]

-- mod + monitorKey ;; move focus to monitor
-- mod + shift + monitorKey ;; move focused window to monitor
-- mod + control + monitorKey ;; swap workspace with monitor
monitorKeys = [xK_Right, xK_Left]

myStartupHook =
  composeAll
    [ spawn "xrandr --output DP-0 --mode 2560x1440 --rate 165 --pos 1080x0 --primary --output HDMI-0 --mode 1920x1080 --rate 60 --pos 0x0 --rotate right",
      spawn "xsetroot -cursor_name left_ptr",
      spawn "feh --no-fehbg --bg-max ~/Pictures/background",
      doOnce $ spawn "systemctl --user start status-watcher",
      doOnce $ spawn "taffybar",
      doOnce $ spawnOn "web" browser,
      doOnce $ spawnOn "dev" $ myTerminal ++ " --working-directory ~/dev/",
      doOnce $ spawnOn "misc" "keepassxc",
      setSessionStarted
    ]

myManageHook =
  manageHook desktopConfig
    <+> composeAll
      [ className =? "steam" --> doShift "launch",
        className =? "heroic" --> doShift "launch",
        className =? "calibre" --> doShift "launch",
        className =? "PrismLauncher" --> doShift "launch",
        className =? "KeePassXC" --> doShift "misc",
        className =? "Tor Browser" --> doFloat,
        isDialog --> doFloat
      ]

myLayoutHook =
  avoidStruts $
    smartBorders $
      toggleLayouts full $
        onWorkspaces ["misc", "launch"] grid $
          tall ||| center ||| grid
  where
    tall = renamed [Replace "layout: tall"] $ magnifierOff $ Tall 1 (1 / 12) (1 / 2)
    center = renamed [Replace "layout: center"] $ magnifierOff $ ThreeColMid 1 (1 / 12) (1 / 2)
    grid = renamed [Replace "layout: grid"] $ magnifiercz (5 / 3) $ Grid (3 / 2)
    full = renamed [Replace "layout: full"] $ lessBorders Screen Full

myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig {XMonad.modMask = modMask}) =
  M.fromList $
    [ ((m, xK_z), refresh),
      ((m_s, xK_q), spawn softRestart),
      ((m_c_s, xK_q), io exitSuccess),
      -- Common Programs
      ((m, xK_t), spawn $ XMonad.terminal conf),
      ((m_s, xK_z), spawn screenLocker),
      ((m, xK_e), spawn editor),
      ((m, xK_b), spawn browser),
      ((m, xK_q), spawn $ dmm "system"),
      ((m_s, xK_r), spawn $ dmm "common"),
      ((m, xK_r), spawn $ dmm "run"),
      -- Window Control
      ((m, xK_m), windows W.focusMaster),
      ((m, xK_Down), windows W.focusDown),
      ((m, xK_Up), windows W.focusUp),
      ((m_s, xK_m), windows W.swapMaster),
      ((m_s, xK_Down), windows W.swapDown),
      ((m_s, xK_Up), windows W.swapUp),
      ((m_s, xK_c), kill),
      ((m_c_s, xK_c), killAll),
      -- Layout Control
      ((m, xK_Tab), sendMessage NextLayout),
      ((m_s, xK_h), sendMessage Shrink),
      ((m_s, xK_l), sendMessage Expand),
      ((m_c, xK_h), sendMessage $ IncMasterN 1),
      ((m_c, xK_l), sendMessage $ IncMasterN (-1)),
      ((m_s, xK_space), sendMessage Magnifier.Toggle),
      ((m, xK_space), sendMessage ToggleStruts),
      ((m, xK_f), sendMessage ToggleLayout),
      ((m_s, xK_f), withFocused toggleFloat),
      ((m_c, xK_f), sinkAll)
    ]
      ++
      -- Workspaces
      [ ((m .|. msk, key), windows $ f workspace)
        | (key, workspace) <- zip wsKeys (XMonad.workspaces conf),
          (f, msk) <- [(W.greedyView, 0), (W.shift, s)]
      ]
      ++
      -- Windows
      [ ( (m .|. msk, key),
          screenWorkspace monitor >>= flip whenJust (windows . f)
        )
        | (key, monitor) <- zip monitorKeys [0 ..],
          (f, msk) <- [(W.view, 0), (W.shift, s), (W.greedyView, c)]
      ]
  where
    m = modMask
    s = shiftMask
    c = controlMask
    m_s = m .|. s
    m_c = m .|. c
    m_c_s = m_c .|. s
    softRestart = "xmonad --recompile; xmonad --restart"
    toggleFloat w =
      windows
        ( \s ->
            if M.member w (W.floating s)
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
