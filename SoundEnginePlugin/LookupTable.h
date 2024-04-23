#pragma once
#include <AK/SoundEngine/Common/IAkPlugin.h>

#include <array>
#include <cmath>
#include <limits>
#include <algorithm>

class SinCosTanLookupTable {
public:
    static constexpr AkUInt32 TABLE_SIZE = 1024;
    static constexpr AkReal32 PI = 3.14159265358979323846f;
    static constexpr AkReal32 TWO_PI = 2.0f * PI;

    SinCosTanLookupTable() {
        for (AkUInt32 i = 0; i < TABLE_SIZE; ++i) {
            AkReal32 angle = static_cast<AkReal32>(i) / TABLE_SIZE * TWO_PI;
            sinTable[i] = std::sin(angle);
            cosTable[i] = std::cos(angle);
            tanTable[i] = std::tan(angle);
        }
    }

    AkReal32 sin(AkReal32 angle) const { return lookup(angle, sinTable); }
    AkReal32 cos(AkReal32 angle) const { return lookup(angle, cosTable); }
    AkReal32 tan(AkReal32 angle) const { return lookup(angle, tanTable); }

public:
    std::array<AkReal32, TABLE_SIZE> sinTable{};
    std::array<AkReal32, TABLE_SIZE> cosTable{};
    std::array<AkReal32, TABLE_SIZE> tanTable{};

    AkReal32 lookup(AkReal32 angle, const std::array<AkReal32, TABLE_SIZE>& table) const {
        AkReal32 position = fmod(angle, 1.0f) * TABLE_SIZE;
        AkUInt32 index = static_cast<AkUInt32>(position);
        AkReal32 frac = position - index;
        AkReal32 a = table[index];
        AkReal32 b = table[(index + 1) % TABLE_SIZE];
        return a * (1 - frac) + b * frac;
    }
}LookupTable;

