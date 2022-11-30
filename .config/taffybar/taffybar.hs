import Control.Monad.IO.Class
import Data.List
import qualified Data.Text as Text
import System.Process
import System.Taffybar
import System.Taffybar.SimpleConfig
import System.Taffybar.Widget
import System.Taffybar.Widget.Generic.Graph
import System.Taffybar.Widget.Generic.PollingLabel
import System.Taffybar.Widget.Workspaces

main =
  startTaffybar $
    toTaffyConfig
      defaultSimpleTaffyConfig
        { startWidgets = [layout, tray, workspaces],
          endWidgets = [dateTime, cpu, memory, disk],
          monitorsAction = usePrimaryMonitor,
          widgetSpacing = 30,
          startupHook = liftIO $ do
            spawnCommand "~/.config/xmonad/after-bar.fish"
            return ()
        }
  where
    tray = sniTrayNew
    disk = showFSInfo "disk: " ["/", "/ext"]
    memory = textMemoryMonitorNew "ram: $used$" 1
    layout = layoutNew defaultLayoutConfig

showFSInfo name fsList =
  liftIO $
    pollingLabelNew 1 $ do
      fsOut <- readProcess "df" ("-kP" : fsList) ""
      let fsList = map (takeLast 2 . words) $ drop 1 $ lines fsOut
      return $ Text.pack $ (name ++) $ intercalate ", " $ map unwords fsList
  where
    takeLast i = take i . reverse

dateTime =
  textClockNewWith
    defaultClockConfig
      { clockFormatString = "%a %b %F %T",
        clockUpdateStrategy = RoundedTargetInterval 1 0
      }

workspaces =
  workspacesNew
    defaultWorkspacesConfig
      { showWorkspaceFn = \ws -> workspaceVisible (workspaceName ws) (workspaceState ws)
      }

workspaceVisible _ Empty = False
workspaceVisible "0" Hidden = False
workspaceVisible _ _ = True

cpu = cpuMonitorNew cpuCfg 0.2 "cpu"
  where
    cpuCfg =
      defaultGraphConfig
        { graphDataColors = [(1, 0.75, 0, 1), (0, 0.75, 1, 1)],
          graphLabel = Just $ Text.pack "cpu: ",
          graphDirection = RIGHT_TO_LEFT,
          graphHistorySize = 50,
          graphWidth = 100,
          graphBackgroundColor = (0, 0, 0, 0),
          graphBorderWidth = 0
        }
