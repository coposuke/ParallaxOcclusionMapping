

Shader "Custom/ParallaxOcclusionMapping.Step1"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}
		_HeightMap("Height Map", 2D) = "white" {}
		_HeightScale("Height", Float) = 0.5
	}

	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
		}

		LOD 200

		Pass
		{
			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag
			//#pragma fragment fragWorld

			sampler2D _MainTex;
			sampler2D _HeightMap;
			float _HeightScale;

			struct Vertex
			{
				float4 position : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct Vertex2Fragment
			{
				float4 position : SV_POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
				float3 objectViewDir : TEXCOORD1;
				float3 objectPos : TEXCOORD2;
			};

			Vertex2Fragment vert(Vertex i)
			{
				Vertex2Fragment o;
				
				o.position = mul(unity_ObjectToWorld, i.position);
				o.normal = i.normal;
				o.uv = i.uv;
				o.objectViewDir = o.position - _WorldSpaceCameraPos.xyz;
				o.objectPos = o.position;
				o.position = mul(UNITY_MATRIX_VP, o.position);

				return o;
			}

			float4 frag(Vertex2Fragment i) : SV_TARGET
			{
				float3 rayDir = normalize(i.objectViewDir);
				float3 rayPos = i.objectPos;
				float2 uv = i.uv;
				
				float rayScale = (-_HeightScale / rayDir.y);
				float3 rayStep = rayDir * rayScale;

				rayPos = rayPos + rayStep;
				rayPos -= i.objectPos;
				uv += rayPos.xz;

				return tex2D(_MainTex, uv);
			}
			
			float4 fragWorld(Vertex2Fragment i) : SV_TARGET
			{
				float3 rayDir = normalize(i.objectViewDir);
				float3 rayPos = i.objectPos;
				float2 uv = {0, 0};
				
				float rayScale = (-_HeightScale / rayDir.y);
				float3 rayStep = rayDir * rayScale;

				rayPos = rayPos + rayStep;
				uv = rayPos.xz;
				
				return tex2D(_MainTex, uv);
			}
			ENDCG
		}
	}
}
