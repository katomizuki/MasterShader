Shader "Unlit/MaskRotation"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		[NoScaleOffset] _MaskTex("Mask Texture(RGB)",2D) = "white" {}
		_RotateSpeed("Rotate Speed", float) = 1.0
	}
	SubShader
	{


		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float uv2 : TEXCOORD1;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOOR01;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _MaskTex;
			fixed _RotateSpeed;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.uv2 = v.uv2;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				half timer = _Time.x;
				// 回転行列
				half angleCos = cos(timer * _RotateSpeed);
				half angleSin = sin(timer * _RotateSpeed);
// 回転行列
				half2x2 rotateMatrix = half2x2(angleCos, -angleCos, angleSin, angleCos);

				half2 uv1 = i.uv - 0.5;
				// 中心合わせ
				i.uv = mul(uv1, rotateMatrix) + 0.5;

				// マスク用画像のピクセルの色を計算
				fixed4 mask = tex2D(_MaskTex, i.uv);
				// 引数の値が0以下なら描画しないAlaphaが0.5以下なら描画しない
				clip(mask.a - 0.5);
				fixed4 col = tex2D(_MainTex, i.uv);
				return col * mask;
			}
			ENDCG
		}
	}
}