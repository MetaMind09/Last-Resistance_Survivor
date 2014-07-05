//
// lua\Survivor_Locale.lua
//
//    Created by:   Lassi lassi@heisl.org
//
//NOTE: this file originated as a copy of combat_Locale.lua from the NS2 Combat Mod
//      by JimWest and MCMLXXXIV, 2012
//

// Replace the normal Locale.ResolveString with our own version!
if Locale then
	if Locale.ResolveString then
		local ns2ResolveFunction = Locale.ResolveString

		function ResolveString(input)
			local resolvedString = nil
			if (kSurvivorLocaleMessages) then
				if (kSurvivorLocaleMessages[input] ~= nil) then
					resolvedString = kSurvivorLocaleMessages[input]
				end
			end
			
			if (resolvedString == nil) then
				resolvedString = ns2ResolveFunction(input)
			end
			
			return resolvedString

		end

		Locale.ResolveString = ResolveString
	end
end