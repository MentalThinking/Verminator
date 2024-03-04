Verminator = Verminator or {
  defaults = {
    max_vermin_per_room = 3,
    wait_time = 10,
    fontSize = 18,
    font = "Ubuntu Mono",
    attack = "kill |t",
    queue_action = "none"
  }
}

local confFile = getMudletHomeDir() .. "/Verminator.lua"

function Verminator.stopTimer()
  stopNamedTimer("Verminator", "waitTimer")
end

function Verminator.save()
  local cfg = {
    max_vermin_per_room = Verminator.max_vermin_per_room,
    wait_time = Verminator.wait_time,
    fontSize = Verminator.fontSize,
    font = Verminator.font,
    attack = Verminator.attack,
    queue_action = Verminator.queue_action,
  }
  table.save(confFile, cfg)
end

function Verminator.load()
  local cfg = {}
  if io.exists(confFile) then
    table.load(confFile, cfg)
  end
  Verminator.max_vermin_per_room = cfg.max_vermin_per_room or 3
  Verminator.wait_time = cfg.wait_time or 10
  Verminator.fontSize = cfg.fontSize or 18
  Verminator.font = cfg.font or "Ubuntu Mono"
  Verminator.attack = cfg.attack or "kill |t"
  Verminator.queue_action = cfg.queue_action or "none"
end

function Verminator.getQueue()
  local game = gmcp.External.Discord.Status.game
  if game == "Aetolia" then
  Verminator.queue_action = "qeb "
  elseif game == "Lusternia" then
  Verminator.queue_action = "sm add "
  end
end

function Verminator.atk(tgt)
  if #gmcp.Room.Players > 1 then
    Verminator.stopTimer()
    Verminator.move()
    return
  end
  local attack = Verminator.attack:gsub("|t", tgt)
  send(""..Verminator.queue_action.."" .. attack)
  Verminator.startTimer()
end

function Verminator.gotOne(tgt)
  if Verminator.queue_action == "sm add " then 
    send(""..Verminator.queue_action.." get " .. tgt)
    end
  Verminator.room_vermin = (Verminator.room_vermin or 0) + 1
  Verminator.total_killed_vermin = Verminator.total_killed_vermin + 1
  if Verminator.room_vermin >= Verminator.max_vermin_per_room then
    Verminator.move()
  end
end

function Verminator.pause()
  Verminator.stopTimer()
  send("vermin")
end

function Verminator.continue()
  send("vermin")
  Verminator.kill()
end

function Verminator.startTimer()
  registerNamedTimer("Verminator", "waitTimer", Verminator.wait_time, "Verminator.move")
  Verminator.updateDisp()
end

function Verminator.disableEventHandlers()
  stopNamedEventHandler("Verminator", "arrived")
end

function Verminator.enableEventHandlers()
  registerNamedEventHandler("Verminator", "arrived", "demonwalker.arrived", "Verminator.kill")
end

function Verminator.kill()
  if #gmcp.Room.Players > 1 then
    Verminator.move()
    return
  end
  if table.contains({"river", "freshwater"}, gmcp.Room.Info.environment) then
    Verminator.move()
    return
  end
  enableTrigger("verminator")
  Verminator.startTimer()
  Verminator.room_vermin = 0
end

function Verminator.move()
  demonwalker:echo("moving on")
  Verminator.stopTimer()
  disableTrigger("verminator")
  raiseEvent("demonwalker.move")
end

function Verminator.start(options)
  Verminator.enableEventHandlers()
  createStopWatch("Verminator")
  resetStopWatch("Verminator")
  startStopWatch("Verminator")
  if not Verminator.container then
    Verminator.makeDisp()
  end
  if Verminator.queue_action == "none" then
  Verminator.getQueue()
  end
  Verminator.total_killed_vermin = 0
  send("vermin")
  demonwalker:init(options)
  registerNamedTimer("Verminator", "updateTimer", 1, "Verminator.updateDisp", true)
end

function Verminator.stop()
  Verminator.disableEventHandlers()
  Verminator.stopTimer()
  stopStopWatch("Verminator")
  demonwalker:echo(string.format("Finished VERMINATING! We got %s vermin and it took %s", Verminator.total_killed_vermin, Verminator.getTime()))
  send("vermin")
  raiseEvent("demonwalker.stop")
  stopNamedTimer("Verminator", "updateTimer")
end

function Verminator.getTime()
  local ttbl = getStopWatchBrokenDownTime("Verminator") or { hours = 0, minutes = 0, seconds = 0 }
  local timeStr = string.format("%02d:%02d:%02d", ttbl.hours, ttbl.minutes, ttbl.seconds)
  return timeStr
end

function Verminator.info(win)
  local total = Verminator.total_killed_vermin or 0
  local room = Verminator.room_vermin or 0
  local roomID = mmp.currentroom
  local time = Verminator.getTime()
  local minutes = (getStopWatchTime("Verminator") or 0) / 60
  local perMin = minutes == 0 and 0 or (total / minutes)
  local waitTime = Verminator.wait_time
  local remainingRooms = demonwalker.remainingRooms and table.size(demonwalker.remainingRooms) or 0
  local template = [[<cyan>  Total:     <green>%d
  <cyan>Room:      <green>%d
  <cyan>WaitTime:  <green>%d
  <cyan>RoomID:    <green>%d
  <cyan>RoomsLeft: <green>%d
  <cyan>Time:      <green>%s
  <cyan>PerMin:    <green>%.02f]]
  local result = string.format(template, total, room, waitTime, roomID, remainingRooms, time, perMin)
  if win then
    if type(win) == "table" then
      win:cecho(result)
    elseif type(win) == "string" then
      cecho(win, result)
    end
  else
    cecho(result)
  end
end

function Verminator.makeDisp()
  Verminator.container = Adjustable.Container:new({
    name = "VerminatorContainer",
    x = 0, y = 0,
    width = "50%",
    height = "50%",
  })
  Verminator.console = Geyser.MiniConsole:new({
    name = "VerminatorConsole",
    x = 0,
    y = 0,
    height = "100%",
    width = "100%",
    font = Verminator.font,
    fontSize = Verminator.fontSize,
    color = "black"
  },Verminator.container)
end

function Verminator.updateDisp()
  Verminator.console:clear()
  Verminator.info(Verminator.console)
end
if not Verminator.console then
  tempTimer(1, function()
    Verminator.load()
    Verminator.makeDisp()
    Verminator.updateDisp()
  end)
end