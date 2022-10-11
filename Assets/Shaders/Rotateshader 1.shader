Shader "Unlit/Rotateshader 1"
{
    Properties
    {
        [NoScaleOffset]_MainTex("Texture", 2D) = "white" {}
        [KeywordEnum(X,Y,Z)] _AXIS("Axis",Int) = 0
        _Rotation("Rotation", Range(-6.28,6.28)) = 0
    }
    SubShader
    {
        Cull off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile _AXIS_X _AXIS_Y _AXIS_Z

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float _Rotation;

            v2f vert (appdata v)
            {
                v2f o;
                half c = cos(_Rotation);
                half s = sin(_Rotation);
                #ifdef _AXIS_X
                   half4x4 rotateMatrixX = half4x4(1, 0, 0, 0,
                                               0, c, -s, 0,
                                               0, s, c, 0,
                                               0, 0, 0, 1);
                v.vertex = mul(rotateMatrixX, v.vertex);
                 #elif _AXIS_Y

                //Y軸中心の回転　定義したキーワードで判定
                half4x4 rotateMatrixY = half4x4(c, 0, s, 0,
                                               0, 1, 0, 0,
                                               -s, 0, c, 0,
                                               0, 0, 0, 1);
                v.vertex = mul(rotateMatrixY, v.vertex);

                #elif _AXIS_Z

                //Z軸中心の回転　定義したキーワードで判定
                half4x4 rotateMatrixZ = half4x4(c, -s, 0, 0,
                                               s, c, 0, 0,
                                               0, 0, 1, 0,
                                               0, 0, 0, 1);
                v.vertex = mul(rotateMatrixZ, v.vertex);
                #endif
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 tex_color = tex2D(_MainTex, i.uv);
                return tex_color;
            }
            ENDCG
        }
    }
}
