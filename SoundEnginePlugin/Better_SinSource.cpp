/*******************************************************************************
The content of this file includes portions of the AUDIOKINETIC Wwise Technology
released in source code form as part of the SDK installer package.

Commercial License Usage

Licensees holding valid commercial licenses to the AUDIOKINETIC Wwise Technology
may use this file in accordance with the end user license agreement provided
with the software or, alternatively, in accordance with the terms contained in a
written agreement between you and Audiokinetic Inc.

Apache License Usage

Alternatively, this file may be used under the Apache License, Version 2.0 (the
"Apache License"); you may not use this file except in compliance with the
Apache License. You may obtain a copy of the Apache License at
http://www.apache.org/licenses/LICENSE-2.0.

Unless required by applicable law or agreed to in writing, software distributed
under the Apache License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
OR CONDITIONS OF ANY KIND, either express or implied. See the Apache License for
the specific language governing permissions and limitations under the License.

  Copyright (c) 2023 Audiokinetic Inc.
*******************************************************************************/

#include "Better_SinSource.h"
#include "../Better_SinConfig.h"
#include "LookupTable.h"

#include <AK/AkWwiseSDKVersion.h>
extern "C" void Sin_func(float* a, float* b, int buffersize, int stepPoint, float Hz);

AK::IAkPlugin* CreateBetter_SinSource(AK::IAkPluginMemAlloc* in_pAllocator)
{
    return AK_PLUGIN_NEW(in_pAllocator, Better_SinSource());
}

AK::IAkPluginParam* CreateBetter_SinSourceParams(AK::IAkPluginMemAlloc* in_pAllocator)
{
    return AK_PLUGIN_NEW(in_pAllocator, Better_SinSourceParams());
}

AK_IMPLEMENT_PLUGIN_FACTORY(Better_SinSource, AkPluginTypeSource, Better_SinConfig::CompanyID, Better_SinConfig::PluginID)

Better_SinSource::Better_SinSource()
    : m_pParams(nullptr)
    , m_pAllocator(nullptr)
    , m_pContext(nullptr)
{
}

Better_SinSource::~Better_SinSource()
{
}

AKRESULT Better_SinSource::Init(AK::IAkPluginMemAlloc* in_pAllocator, AK::IAkSourcePluginContext* in_pContext, AK::IAkPluginParam* in_pParams, AkAudioFormat& in_rFormat)
{
    m_pParams = (Better_SinSourceParams*)in_pParams;
    m_pAllocator = in_pAllocator;
    m_pContext = in_pContext;

    m_durationHandler.Setup(m_pParams->RTPC.fDuration, in_pContext->GetNumLoops(), in_rFormat.uSampleRate);

    Hz = static_cast<float>(600) / in_rFormat.uSampleRate;

    return AK_Success;
}

AKRESULT Better_SinSource::Term(AK::IAkPluginMemAlloc* in_pAllocator)
{
    AK_PLUGIN_DELETE(in_pAllocator, this);
    return AK_Success;
}

AKRESULT Better_SinSource::Reset()
{
    return AK_Success;
}

AKRESULT Better_SinSource::GetPluginInfo(AkPluginInfo& out_rPluginInfo)
{
    out_rPluginInfo.eType = AkPluginTypeSource;
    out_rPluginInfo.bIsInPlace = true;
    out_rPluginInfo.uBuildVersion = AK_WWISESDK_VERSION_COMBINED;
    return AK_Success;
}

void Better_SinSource::Execute(AkAudioBuffer* out_pBuffer)
{
    m_durationHandler.SetDuration(5);
    m_durationHandler.ProduceBuffer(out_pBuffer);

   

    const AkUInt32 uNumChannels = out_pBuffer->NumChannels();


    AkReal32* AK_RESTRICT pBuf = (AkReal32* AK_RESTRICT)out_pBuffer->GetChannel(0);

    Sin_func(&LookupTable.sinTable[0], pBuf, out_pBuffer->uValidFrames, BufferSize, Hz);


    BufferSize += out_pBuffer->MaxFrames();
}

AkReal32 Better_SinSource::GetDuration() const
{
    return m_durationHandler.GetDuration() * 1000.0f;
}
