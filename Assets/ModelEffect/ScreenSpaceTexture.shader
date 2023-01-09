Shader "Unlit/ScreenSpaceTexture"
{
    Properties
    {
        [Header(Outline)]
        _OutlineVal("Outline value", Range(0., 2)) = 1.
        _OutlineCol("Outline col", color) = (1,1,1,1)
        [Header(Texture)]
        _MainTex ("Texture", 2D) = "white" {}
        _Zoom("Zoom", Range(0.5, 20)) = 1
        _SpeedX("Speed along X", Range(-1, 1)) = 0
        _SpeedY("Speed along Y", Range(-1, 1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Geometry" "RenderType"="Opaque" }

        Pass
        {
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float _OutlineVal;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // モデルビュー行列の逆行列の転置　法線をビュー空間へ変換。
                float3 normal = mul((float3x3) UNITY_MATRIX_IT_MV, v.normal);
                // 法線のクリップ空間を計算
                normal.x *= UNITY_MATRIX_P[0][0];
                normal.y *= UNITY_MATRIX_P[1][1];
                o.pos.xy += _OutlineVal * normal.xy;
                return o;
            }

            float4 _OutlineCol;

            fixed4 frag (v2f i) : SV_Target
            {
                return _OutlineCol;
            }
            ENDCG
        }
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float4 vert(appdata_base v) : SV_POSITION {
                return UnityObjectToClipPos(v.vertex);
            }


            sampler2D _MainTex;
            float _Zoom;
            float _SpeedX;
            float _SpeedY;
            fixed4 frag(float4 i : VPOS) : SV_Target {
                float2 offset = float2(_Time.y * _SpeedX, _Time.y * _SpeedY) / _Zoom; 
                float2 uv = (i.xy / _ScreenParams.xy) + offset; 
                return tex2D(_MainTex, uv);
            }
            ENDCG
            }
        }
}
