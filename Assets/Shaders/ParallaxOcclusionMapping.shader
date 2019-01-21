

Shader "Custom/ParallaxOcclusionMapping"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}
		_HeightMap("Height Map", 2D) = "black" {}
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
				float2 uv = i.uv;
				float2 uvStart = i.uv;
				float3 rayPos = i.objectPos;
				float3 rayPosStart = i.objectPos;
				float3 rayDir = normalize(i.objectViewDir);
				float rayHeight = 0.0;
				float objHeight = tex2D(_HeightMap, uv).r * _HeightScale - _HeightScale;

				const int HeightSamples = 32;
				const float HeightPerSample = 1.0 / HeightSamples;
				float rayScale = (-_HeightScale / rayDir.y);
				float3 rayStep = rayDir * rayScale * HeightPerSample;

				for (int i = 0; i < HeightSamples && objHeight < rayHeight; ++i)
				{
					rayPos += rayStep;
					uv = uvStart + rayPos.xz - rayPosStart.xz;
					
					objHeight = tex2D(_HeightMap, uv).r;
					objHeight = objHeight * _HeightScale - _HeightScale;
					rayHeight = rayPos.y - rayPosStart.y;
				}
				
				// Parallax Occlusion Mapping(高さ情報を元に2点間の線形補間する)
				float2 nextObjPoint = uv;
				float2 prevObjPoint = uv - rayStep.xz;
				float nextHeight = objHeight;
				float prevHeight = tex2D(_HeightMap, prevObjPoint).r * _HeightScale - _HeightScale;
				nextHeight -= rayHeight;
				prevHeight -= rayHeight - rayStep.y;

				float weight = nextHeight / (nextHeight - prevHeight);
				uv = lerp(nextObjPoint, prevObjPoint, weight);

				return tex2D(_MainTex, uv);
			}
			ENDCG
		}
	}
}
