import Data.Text
import System.Taffybar
import System.Taffybar.Information.CPU
import System.Taffybar.SimpleConfig
import System.Taffybar.Widget
import System.Taffybar.Widget.Workspaces
import System.Taffybar.Widget.Generic.Graph
import System.Taffybar.Widget.Generic.PollingGraph

main = startTaffybar myConfig

myConfig = toTaffyConfig defaultSimpleTaffyConfig
    { startWidgets = [ layout, workspaces ]
    , centerWidgets = [ title ]
    , endWidgets = [ time, date, cpu, memory, disk, tray ]
    , widgetSpacing = 18
    , barHeight = 36
    }
  where
    tray = sniTrayThatStartsWatcherEvenThoughThisIsABadWayToDoIt

memory = textMemoryMonitorNew "ram: $used$" 1
disk = fsMonitorNew 1 ["/"]

date = textClockNewWith defaultClockConfig
  { clockFormatString = "%F, %a"
  , clockUpdateStrategy = RoundedTargetInterval 10 0.0
  }
time = textClockNewWith defaultClockConfig
  { clockFormatString = "%T"
  , clockUpdateStrategy = RoundedTargetInterval 1 0.0
  }

layout = layoutNew LayoutConfig
  { formatLayout = (\x ->
      return $
      pack $
      "|| " ++
      unpack x ++
      " ||") }

title = windowsNew WindowsConfig
  { getMenuLabel = truncatedGetMenuLabel 108
  , getActiveLabel = truncatedGetActiveLabel 72
  }

workspaces = workspacesNew defaultWorkspacesConfig { showWorkspaceFn = (\x ->
  case (workspaceName x, workspaceState x) of
    ("bg", Hidden) -> False
    (_, Empty) -> False
    otherwise -> True
  ) }

cpu = pollingGraphNew cpuCfg 0.5 cpuCallback
  where
    cpuCallback = do
      (_, systemLoad, totalLoad) <- cpuLoad
      return [ totalLoad, systemLoad ]
    cpuCfg = defaultGraphConfig
      { graphDataColors = [ (0, 1, 0, 1), (1, 0, 1, 0.5)]
      , graphBackgroundColor = (0, 0, 0, 0)
      , graphBorderWidth = 0
      , graphLabel = Just $ pack "cpu: "
      , graphDirection = RIGHT_TO_LEFT
      }


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
