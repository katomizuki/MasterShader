Shader "Unlit/ShisaMapping"
{
	Properties
	{
		_MainColor("MainColor", Color) = (1,1,1,1)
		_Reflection("Reflection", Range(0,10)) = 1
		_Specular("Specular", Range(0,10)) = 1
		_HeightFactor("Height Factor", Range(0.0, 0.1)) = 0.02
		_NormalMap("Normal Map", 2D) = "bump" { }
		_HeightMap("HeightMap", 2D) = "white" { }
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 lightDir: TEXCOORD1;
				float3 viewDir: TEXCOORD2;
			};

			float4 _MainColor;
			float _Reflection;
			float _Specular;
			float _HeightFactor;
			sampler2D _NormalMap;
			sampler2D _HeightMap;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				TANGENT_SPACE_ROTATION;

				o.lightDir = normalize(mul(rotation, ObjSpaceLightDir(v.vertex)));
				o.viewDir = normalize(mul(rotation, ObjSpaceViewDir(v.vertex)));

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float4 height = tex2D(_HeightMap, i.uv);
				i.uv += i.viewDir.xy * height.r * _HeightFactor;
				float3 normal = UnpackNormal(tex2D(_NormalMap, i.uv));
				float3 refVec = reflect(-i.viewDir, normal);
				float dotVR = dot(i.viewDir, refVec);
				dotVR = max(0, dotVR);
				dotVR = pow(dotVR, _Reflection);
				float3 specular = _LightColor0.xyz * dotVR * _Specular;
				float4 finalColor = _MainColor + float4(specular, 1);
				return finalColor;
			}
			ENDCG
		}
	}
}