import           Data.Text
import           System.Taffybar
import           System.Taffybar.SimpleConfig
import           System.Taffybar.Widget
import           System.Taffybar.Widget.Generic.Graph
import           System.Taffybar.Widget.Workspaces

main = startTaffybar $ toTaffyConfig defaultSimpleTaffyConfig
  { startWidgets  = [layout, workspaces]
  , centerWidgets = [tray]
  , endWidgets    = [dateTime, cpu, memory, disk]
  , widgetSpacing = 30
  , barHeight     = 30
  }

disk = fsMonitorNew 1 ["/"]
memory = textMemoryMonitorNew "ram: $used$" 1
tray = sniTrayNew
layout = layoutNew defaultLayoutConfig

dateTime = textClockNewWith defaultClockConfig
  { clockFormatString   = "%a %b %F %T"
  , clockUpdateStrategy = RoundedTargetInterval 1 0
  }

workspaces = workspacesNew defaultWorkspacesConfig
  { showWorkspaceFn =
    (\ws -> workspaceVisible (workspaceName ws) (workspaceState ws))
  }

workspaceVisible _   Empty  = False
workspaceVisible "0" Hidden = False
workspaceVisible _   _      = True

cpu = cpuMonitorNew cpuCfg 0.2 "cpu"
 where
  cpuCfg = defaultGraphConfig
    { graphDataColors      = [(1, 0.75, 0, 1), (0, 0.75, 1, 1)]
    , graphLabel           = Just $ pack "cpu: "
    , graphDirection       = RIGHT_TO_LEFT
    , graphHistorySize     = 50
    , graphWidth           = 100
    , graphBackgroundColor = (0, 0, 0, 0)
    , graphBorderWidth     = 0
    }
