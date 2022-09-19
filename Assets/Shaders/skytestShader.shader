Shader "Unlit/skytestShader"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Background"
            "Queue"="Background"
            "PreviewType"="SkyBox"
        }

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
            };

            struct v2f
            {
                float3 worldPos : WORLD_POS;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 今見ているワールド座標をノーマライズする
                float3 dir = normalize(i.worldPos);
                // ラジアンを算出する atan2で直交座標のラジアンを出す。
                //スカイボックスの円周上のラジアンが返される。
                // asin(x)は -PI/2 ~ PI/2の間で逆正弦を返す。 xの範囲は-1~1 asin(x)=>ラジアンで角度を返す。
                float2 rad = float2(atan2(dir.x, dir.z), asin(dir.y));
                // ラジアン2PI 2分の1PIででそれぞれわる UVのy軸方向のストレッチはasin(x) / 3.14 / 2)らしい
                float2 uv = rad / float2(2.0 * UNITY_PI, UNITY_PI / 2);
                // テクスチャとUV座標から色の計算
                float4 color = tex2D(_MainTex, uv);
                return color;
            }
            ENDCG
        }
    }
}

