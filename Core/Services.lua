-- Services.
---@module Core.Services
local Services = {}

Services.playersService = game:GetService("Players")
Services.replicatedStorage = game:GetService("ReplicatedStorage")
Services.runService = game:GetService("RunService")
Services.userInputService = game:GetService("UserInputService")
Services.workspace = game:GetService("Workspace")
Services.camera = workspace.CurrentCamera
Services.tweenService = game:GetService("TweenService")
Services.lighting = game:GetService("Lighting")
Services.soundService = game:GetService("SoundService")
Services.httpService = game:GetService("HttpService")
Services.starterGui = game:GetService("StarterGui")
Services.coreGui = game:GetService("CoreGui")

return Services