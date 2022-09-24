Shader "Unlit/repeadShader"
{
    Properties
    {
        _Color1("Color 1",Color) = (0, 0, 0, 1)
        _Color2("Color 2", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float3 worldPos : WORLD_POS;
                float4 vertex : SV_POSITION;
            };

            float4 _Color1;
            float4 _Color2;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 端っこ(float2(1,1))を正規化して今見てるワールド座標の内積を出す
                // ポジションとベクトルの内積をとることでベクトルの方向へグラデーションをとる
                float dotResult = dot(i.worldPos, normalize(float2(1,1)));
                //内積結果を正の数にする
                float repeat = abs(dotResult);
                // 1でわり座標を繰り返すにする
                float m = fmod(repeat, 1);
                // 
                float interpolation = step(m, 0.1);
                fixed4 col = lerp(_Color1, _Color2, interpolation);
                return col;
            }
            ENDCG
        }
    }
}
