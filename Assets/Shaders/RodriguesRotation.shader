Shader "Unlit/RodriguesRotation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Axis("Axis", Vector) = (0,0,0,0)
        _Theta("Theta", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4  _Axis;
            float _Theta;
// 回転
            fixed3 rotate(fixed3 pos, fixed3 axis, float theta)
            {
                fixed3 axisN = normalize(axis);

                if (length(axisN) < 0.001)
                {
                    return pos;
                }

                // ラジアン
                half radTheta = radians(theta);
                // サインθ
                fixed sinTheta = sin(radTheta);
                // コサインθ
                fixed cosTheta = cos(radTheta);
                // 
                fixed a = 1.0 - cosTheta;
// 行列の計算を一回でできる。
                //　ロドリゲスの回転公式
                // ベクトル空間において与えられた回転軸に対して回転を行うための効率的なアルゴリズム
                // ベクトルを変換しまくって正射影ベクトルによりこの公式が成り立つ。「
                fixed3x3 m = fixed3x3(axisN.x * axisN.x * a + cosTheta,
                    axisN.y * axisN.x * a + axisN.z * sinTheta,
                    axisN.z * axisN.x * a - axisN.y * sinTheta,
                    axisN.x * axisN.y * a - axisN.z * sinTheta,
                    axisN.y * axisN.y * a + cosTheta,
                    axisN.z * axisN.y * a + axisN.x * sinTheta,
                    axisN.x * axisN.z * a + axisN.y * sinTheta,
                    axisN.y * axisN.z * a - axisN.x * sinTheta,
                    axisN.z * axisN.z * a + cosTheta);
                return mul(m, pos);
            }

            v2f vert (appdata v)
            {
                v2f o;
                v.vertex.xyz = rotate(v.vertex.xyz, _Axis.xyz, _Theta);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
