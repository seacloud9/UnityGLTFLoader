﻿Shader "GLTF/GLTFStandard" {
	
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}

        _Metallic("Metallic", Range(0,1)) = 0.0
		_Roughness("Roughness", Range(0,1)) = 0.5
		_MetallicRoughnessMap("Metallic Roughness", 2D) = "black" {}

        _BumpScale("Scale", Float) = 1.0
		_BumpMap("Normal Map", 2D) = "bump" {}
		
		_OcclusionMap("Occlusion", 2D) = "white" {}
		_OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0

		_EmissionColor("Color", Color) = (1,1,1,0)
		_EmissionMap("Emission", 2D) = "black" {}

		[HideInInspector] _Mode ("__mode", Float) = 0.0
		[HideInInspector] _SrcBlend ("__src", Float) = 1.0
		[HideInInspector] _DstBlend ("__dst", Float) = 0.0
		[HideInInspector] _ZWrite ("__zw", Float) = 1.0
	}

	CGINCLUDE
	#define UNITY_SETUP_BRDF_INPUT MetallicSetup
	ENDCG

	SubShader
	{
		Tags { "RenderType"="Opaque" "PerformanceChecks"="False" }
		LOD 300
	

		// ------------------------------------------------------------------
		//  Base forward pass (directional light, emission, lightmaps, ...)
		Pass
		{
			Name "FORWARD" 
			Tags { "LightMode" = "ForwardBase" }

			Blend [_SrcBlend] [_DstBlend]
			ZWrite [_ZWrite]
			Cull [_Cull]

			CGPROGRAM
			#pragma target 3.0

			// -------------------------------------

			#pragma multi_compile _ _ALPHATEST_ON _ALPHABLEND_ON
			#define _NORMALMAP 1
			#define _EMISSION 1
			#define _METALLICGLOSSMAP 1
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog

			#pragma vertex vertBase
			#pragma fragment fragBase
			#include "GLTFStandardInput.cginc"
			#include "UnityStandardCoreForward.cginc"

			ENDCG
		}
		// ------------------------------------------------------------------
		//  Additive forward pass (one light per pass)
		Pass
		{
			Name "FORWARD_DELTA"
			Tags { "LightMode" = "ForwardAdd" }
			Cull [_Cull]
			Blend [_SrcBlend] One
			Fog { Color (0,0,0,0) } // in additive pass fog should be black
			ZWrite Off
			ZTest LEqual

			CGPROGRAM
			#pragma target 3.0

			// -------------------------------------

			#define _NORMALMAP 1
			#pragma multi_compile _ _ALPHATEST_ON _ALPHABLEND_ON
			#define _METALLICGLOSSMAP 1

			#pragma multi_compile_fwdadd_fullshadows
			#pragma multi_compile_fog


			#pragma vertex vertAdd
			#pragma fragment fragAdd
			#include "GLTFStandardInput.cginc"
			#include "UnityStandardCoreForward.cginc"

			ENDCG
		}
		// ------------------------------------------------------------------
		//  Shadow rendering pass
		Pass {
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }

			ZWrite On ZTest LEqual

			CGPROGRAM
			#pragma target 3.0

			// -------------------------------------


			#pragma multi_compile _ _ALPHATEST_ON _ALPHABLEND_ON
			#pragma multi_compile_shadowcaster

			#pragma vertex vertShadowCaster
			#pragma fragment fragShadowCaster

			#include "UnityStandardShadow.cginc"

			ENDCG
		}
	}

	SubShader {
		Cull [_Cull]
		Blend [_SrcBlend] [_DstBlend]
		ZWrite [_ZWrite]
		LOD 200
		
		Pass {
			CGPROGRAM
			// Mobile Shader
			#pragma target 2.0
			// Vertex Colors
			#pragma multi_compile _ VERTEX_COLOR_ON
			// Occlusion packed in red channel of MetallicRoughnessMap
			#pragma multi_compile _ OCC_METAL_ROUGH_ON
			#pragma multi_compile _ _ALPHATEST_ON _ALPHABLEND_ON
			#include "GLTFMobileCommon.cginc"
			#pragma vertex gltf_mobile_vert
			#pragma fragment gltf_mobile_frag
			ENDCG
		}
	}

	SubShader {
		Cull [_Cull]
		Blend [_SrcBlend] [_DstBlend]
		ZWrite [_ZWrite]
		LOD 100

		Pass {
			CGPROGRAM
			// Vertex Lit Shader
			#pragma target 2.0
			// Vertex Colors
			#pragma multi_compile _ VERTEX_COLOR_ON
			// Occlusion packed in red channel of MetallicRoughnessMap
			#pragma multi_compile _ OCC_METAL_ROUGH_ON
			#pragma multi_compile _ _ALPHATEST_ON _ALPHABLEND_ON
			#pragma multi_compile_fwdbase	
			#pragma multi_compile_fog
			#include "GLTFVertexLitCommon.cginc"
			#pragma vertex gltf_vertex_lit_vert
			#pragma fragment gltf_vertex_lit_frag
			ENDCG
		}
	}
}
