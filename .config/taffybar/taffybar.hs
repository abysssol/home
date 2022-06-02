import           Data.Text
import           System.Taffybar
import           System.Taffybar.Information.CPU
import           System.Taffybar.SimpleConfig
import           System.Taffybar.Widget
import           System.Taffybar.Widget.Generic.Graph
import           System.Taffybar.Widget.Generic.PollingGraph
import           System.Taffybar.Widget.Workspaces

main = startTaffybar myConfig

myConfig = toTaffyConfig defaultSimpleTaffyConfig
    { startWidgets  = [tray, layout, workspaces]
    , centerWidgets = [title]
    , endWidgets    = [time, date, cpu, memory, disk]
    , widgetSpacing = 18
    , barHeight     = 36
    }
    where tray = sniTrayThatStartsWatcherEvenThoughThisIsABadWayToDoIt

memory = textMemoryMonitorNew "ram: $used$" 1
disk = fsMonitorNew 1 ["/", "/ext"]

date = textClockNewWith defaultClockConfig
    { clockFormatString   = "%F, %a"
    , clockUpdateStrategy = RoundedTargetInterval 10 0.0
    }
time = textClockNewWith defaultClockConfig
    { clockFormatString   = "%T"
    , clockUpdateStrategy = RoundedTargetInterval 1 0.0
    }

layout = layoutNew LayoutConfig
    { formatLayout = (\x -> return $ pack $ "|| " ++ unpack x ++ " ||")
    }

title = windowsNew WindowsConfig { getMenuLabel   = truncatedGetMenuLabel 100
                                 , getActiveLabel = truncatedGetActiveLabel 60
                                 }

workspaces = workspacesNew defaultWorkspacesConfig
    { showWorkspaceFn = (\x -> case (workspaceName x, workspaceState x) of
                            (_   , Empty ) -> False
                            ("0", Hidden) -> False
                            otherwise      -> True
                        )
    }

cpu = pollingGraphNew cpuCfg 0.5 cpuCallback
  where
    cpuCallback = do
        (_, systemLoad, totalLoad) <- cpuLoad
        return [totalLoad, systemLoad]
    cpuCfg = defaultGraphConfig
        { graphDataColors      = [(0, 1, 0, 1), (1, 0, 1, 0.5)]
        , graphBackgroundColor = (0, 0, 0, 0)
        , graphBorderWidth     = 0
        , graphLabel           = Just $ pack "cpu: "
        , graphDirection       = RIGHT_TO_LEFT
        }
