Shader "Unlit/BlendOcclusion"
{
	SubShader
	{
		Tags { "Queue"="geometry-1" "LightMode"="ForwardBase" }
		Blend One OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwd_base
			
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			float _ShadowIntensity;
			float _ShadowDistance;

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 worldPos : WORLD_POS;
				float3 worldNormal : TEXCOORD0;
				SHADOW_COORDS(1);
			};

			
			v2f vert (appdata v)
			{
				v2f o;
				TRANSFER_SHADOW(o);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				return o;
			}
			
			fixed4 frag (v2f i) : COLOR 
			{
				float viewDirLength = length(_WorldSpaceCameraPos - i.worldPos);
				float cameraToObjLength = clamp(viewDirLength, 0, _ShadowDistance);
				float3 L = normalize((_WorldSpaceLightPos0.xyz)); // 放射ベクトル
				float3 N = normalize(i.worldNormal); // サーフェイス法線ベクトル
				float dotNL = dot(N,L);
				float front = step(dotNL, 0); // 内積が負の数だと裏側ということになる。表側だけ何かしたい場合はこの処理はほぼセット。
				float attenuation = SHADOW_ATTENUATION(i);
				float fade = pow(cameraToObjLength / _ShadowDistance, _ShadowDistance);
				return float4(0,0,0,(1 - attenuation) * _ShadowIntensity * front * fade);
			}
			ENDCG
		}
	}
}