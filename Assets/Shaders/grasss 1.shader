Shader "CAGraphicsAcademy/ToonOutline"
{
    Properties
    {
		_MainTex("Base (RGB)", 2D) = "white" { }
		_MainColor("Main Color", Color) = (.5,.5,.5,1)
		_OutlineColor("Outline Color", Color) = (0,0,0,1)
		_OutlineWidth("Outline Width", Range(0, 0.1)) = .005
    }

	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		float2 uv       : TEXCOORD0;
		float3 normal : NORMAL;
	};

	struct v2f 
	{
		float4 pos : SV_POSITION;
		float2 uv       : TEXCOORD0;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;
	uniform float4 _MainColor;
	uniform float _OutlineWidth;
	uniform float4 _OutlineColor;

	ENDCG

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
		Pass
		{
			Name "BASE" //本体部分を描画するパスの名前

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex); //頂点をMVP行列変換
				o.uv = TRANSFORM_TEX(v.uv, _MainTex); //テクスチャスケールとオフセットを加味
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				half4 c = tex2D(_MainTex, i.uv); //UVをもとにテクスチャカラーをサンプリング
				c.rgb *= _MainColor; //ベースカラーを乗算
				return c;
			}
			ENDCG
		}
        Pass
        {
			Name "OUTLINE" //アウトライン部分を描画するパスの名前

			Cull Front //表面をカリング（描画しない）

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex); //頂点をMVP行列変換

				float3 norm = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal)); //モデル座標系の法線をビュー座標系に変換
				float2 offset = TransformViewToProjection(norm.xy); //ビュー座標系に変換した法線を投影座標系に変換

				o.pos.xy += offset * UNITY_Z_0_FAR_FROM_CLIPSPACE(o.pos.z) * _OutlineWidth; //法線方向に頂点位置を押し出し

				return o;
			}

            fixed4 frag (v2f i) : SV_Target
            {
                return _OutlineColor; //プロパティに設定したアウトラインカラーを表示
            }
            ENDCG
        }
    }
}
