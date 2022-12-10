Shader "Unlit/SimpleRotation" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Theta2D ("Theta2D", float) = 0
        _ThetaX ("Theta X", float) = 0
        _ThetaY ("Theta Y", float) = 0
        _ThetaZ ("Theta Z", float) = 0
        [Toggle] _Is3D ("Is 3D", int) = 0
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Theta2D;
            float _ThetaX;
            float _ThetaY;
            float _ThetaZ;
            int _Is3D;

            // 2次元の回転
            float4 Rotate2D(float4 pos) {
                float sinTheta = sin(_Theta2D);
                float cosTheta = cos(_Theta2D);

                // 2次元の回転行列
                float4x4 rot = float4x4(
                    float4(cosTheta, sinTheta, 0, 0),
                    float4(-sinTheta, cosTheta, 0, 0),
                    float4(0, 0, 0, 0),
                    float4(0, 0, 0, 1)
                );
                pos = mul(pos, rot);
                return pos;
            }

            // 3次元の回転
            float4 Rotate3D(float4 pos) {
                float radX = radians(_ThetaX);
                float radY = radians(_ThetaY);
                float radZ = radians(_ThetaZ);

                float sinX = sin(radX);
                float cosX = cos(radX);

                // 3次元のX軸の回転行列
                float4x4 rotX = float4x4(
                    float4(1, 0, 0, 0),
                    float4(0, cosX, sinX, 0),
                    float4(0, -sinX, cosX, 0),
                    float4(0, 0, 0, 1)
                );

                float sinY = sin(radY);
                float cosY = cos(radY);

                // 3次元のY軸の回転行列
                float4x4 rotY = float4x4(
                    float4(cosY, 0, -sinY, 0),
                    float4(0, 1, 0, 0),
                    float4(sinY, 0, cosY, 0),
                    float4(0, 0, 0, 1)
                );

                float sinZ = sin(radZ);
                float cosZ = cos(radZ);

                // 3次元のZ軸の回転行列
                float4x4 rotZ = float4x4(
                    float4(cosZ, sinZ, 0, 0),
                    float4(-sinZ, cosZ, 0, 0),
                    float4(0, 0, 1, 0),
                    float4(0, 0, 0, 1)
                );

                pos = mul(pos, rotX);
                pos = mul(pos, rotY);
                pos = mul(pos, rotZ);
                return pos;
            }

            v2f vert (appdata v) {
                v2f o;
                // lerpとstepを用いて、boolで2次元、3次元を切り替えられるように
                v.vertex = lerp(Rotate2D(v.vertex), Rotate3D(v.vertex), step(1, _Is3D));
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}