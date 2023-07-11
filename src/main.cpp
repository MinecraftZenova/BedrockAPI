#define LOG_CONTEXT "BedrockAPI"

#include <Zenova.h>
#include <Zenova/Minecraft/Mod.h>

#include "Hooks/InputHooks.h"
#include "Hooks/ResourceHooks.h"

#include <chrono>
#include <Windows.h>

MOD_FUNCTION void PluginAddMod(Zenova::ModContext& ctx) {
    Zenova::PackManager::addMod(ctx.GetFolder());
}

void ModLoad(Zenova::ModContext& ctx) {
    Zenova_Info("Minecraft's Version: {}", Zenova::Version::launched().toString());
    Zenova_Info("Minecraft's BaseAddress: {:x}", Zenova::Platform::GetMinecraftBaseAddress());
    Zenova_Info("Minecraft's Data Folder: {}", Zenova::Platform::GetMinecraftFolder()); 
    char Filename[MAX_PATH];
    GetModuleFileNameA(NULL, Filename, sizeof(Filename));
    Zenova_Info("Minecraft's Folder: {}", Filename);
    Zenova::Version ver(1, 14, 60, 5);
    Zenova_Info("Minecraft's Folder: {}", ver == "1.14.60.5");

    Zenova::createResourceHooks();
    Zenova::createInputHooks();
}

void ModUpdate() {
    // todo: hook into minecraft's global tick function
    namespace chrono = std::chrono;
    using tick = chrono::duration<int, std::ratio<1, 20>>;

    using clock = std::chrono::steady_clock;
    static std::chrono::time_point<clock> tickTimer = clock::now();

    if (chrono::duration_cast<tick>(clock::now() - tickTimer).count() >= 1) {
        tickTimer = clock::now();
        for (auto& mod : Zenova::GetMods()) {
            CALL_MOD_FUNC(mod.GetHandle(), ModTick);
        }
    }
}