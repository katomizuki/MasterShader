Shader "Unlit/Liquid" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        [Header(Shape)]
        _HeightMax ("Height Max", Float) = 1.0
        _HeightMin ("Height Min", Float) = 0.0
        _TopColor ("Top Color", Color) = (0.5, 0.75, 1,1)
        _BottomColor ("Bottom Color", Color) = (0, 0.25, 1, 1)
        [Header(Wave)]
        _WaveSpeed ("Wave Speed", Float) = 1.0
        _WavePower ("Wave Power", Float) = 0.1
        _WaveLength ("Wave Length", Float) = 1.0
        [Header(Rim)]
        _RimColor ("Rim Light Color", Color) = (1, 1, 1, 1)
        _RimPower("Rim Light Power", Float) = 3
        [Header(Surface)]
        _SurfaceColor ("Surface Color", Color) = (1, 1, 1, 1)
        [HideInInspector]
        _TransformPositionY ("Transform Position Y", float) = 0
    }
    SubShader {
        Tags { "RenderType"="Opaque"}
        LOD 100

        Pass {
            ZWrite On
            ZTest LEqual
            Blend Off
            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float3 viewDir : TEXCOORD1;
                float4 worldPos : TEXCOORD2;
                float3 normal : NORMAL;
                float4 vertex : POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _TopColor;
            half4 _BottomColor;
            half4 _RimColor;
            float _RimPower;
            float _HeightMax;
            float _HeightMin;
            float _WaveSpeed;
            float _WavePower;
            float _WaveLength;
            float _TransformPositionY;

            v2f vert (appdata v) {
                v2f o;
                // ワールド座標を取得
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                // いつものプロジェクション行列を乗算する
                o.vertex = mul(UNITY_MATRIX_VP,o.worldPos);
                //　ワールド座標での法線を出す
                o.normal = UnityObjectToWorldNormal(v.normal);
                // プラットフォームごとの違いを吸収
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // 視線ベクトルを算出して正規化
                o.viewDir = normalize(_WorldSpaceCameraPos - o.worldPos.xyz);
                return o;
            }

            half4 frag (v2f i) : SV_Target {
                //  Script側からローカル座標が渡される。
                float heightMax = _HeightMax + _TransformPositionY;
                float heightMin = _HeightMin + _TransformPositionY;
                // sin波で波を表現 ローカル座標 + 最大の波の高さ + サイン波 
                float height = heightMax + sin((i.worldPos.x + i.worldPos.z) * _WaveLength + _Time.w * _WaveSpeed) * _WavePower;
                // 0以下は描画しないようにすることで波のようになる。
                clip(height - i.worldPos.y);
                // テキスチャマッピング
                half4 col = tex2D(_MainTex, i.uv);
                // 最小値
                float totalHeight = heightMax - heightMin;
                float realHeight = i.worldPos.y - heightMax;
                
                float rate = saturate(realHeight / totalHeight);
                // 下の方の色と上部の色をrateを閾値として線形補間
                col.rgb *= lerp(_BottomColor.rgb, _TopColor.rgb, rate);
                // 法線と視線方向の内積をとり丸め込む
                float rim = 1 - saturate(dot(i.normal, i.viewDir));
                // 色を乗算してあげる
                col.rgb += pow(rim, _RimPower) * _RimColor;
                return col;
            }
            ENDCG
        }

        Pass {
            ZWrite On
            ZTest LEqual
            Blend Off
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
            };

            struct v2f {
                UNITY_FOG_COORDS(0)
                float4 worldPos : TEXCOORD3;
                float4 vertex : SV_POSITION;
            };

            half4 _SurfaceColor;
            float _HeightMax;
            float _WaveSpeed;
            float _WavePower;
            float _WaveLength;
            float _TransformPositionY;

            v2f vert (appdata v) {
                v2f o;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex );
                o.vertex = mul(UNITY_MATRIX_VP,o.worldPos);
                return o;
            }

            half4 frag (v2f i) : SV_Target {
                float heightMax = _HeightMax + _TransformPositionY;
                float height = heightMax + sin( (i.worldPos.x + i.worldPos.z) * _WaveLength + _Time.w * _WaveSpeed) * _WavePower;
                clip(height - i.worldPos.y);
                half4 col = _SurfaceColor;
                return col;
            }
            ENDCG
        }
    }
}