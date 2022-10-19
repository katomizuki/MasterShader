Shader "Unlit/NormalMapping"
{
    Properties
    {
        _MainColor("MainColor", Color) = (1,1,1,1)
        _Reflection("Reflection", Range(0, 10)) = 1
        _Specular("Specular", Range(0, 10)) = 1
        _NomalMap("Normal map", 2D) = "bump" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            float4 _MainColor;
            float _Reflecition;
            float _Specular;
            sampler2D _NormalMap;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                // 接空間の行列の取得
                TANGENT_SPACE_ROTATION;
                // ライトの方向ベクトルを接空間に変換　rotationに行列が入る。
                // オブジェクト空間から見たライト方向を算出する関数。（戻り値は正規化されてない）
                o.lightDir = normalize(mul(rotation, ObjSpaceLightDir(v.vertex)));
                // カメラの方向ベクトルを接空間に変換
                // オブジェクト空間絡みた視線ベクトルを算出する関数。（戻り値は正規化されてない）
                o.viewDir = normalize(mul(rotation, ObjSpaceViewDir(v.vertex)));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // ノーマルマップから法線を取得　バンプマップのくだりで出てくる関数
                float3 normal = UnpackNormal(tex2D(_NormalMap, i.uv));
               // ライトベクトルと法線ベクトルから反射ベクトル
                float3 refVec = reflect(-i.lightDir, normal);
                // 反射ベクトルと視線ベクトルの内積を出す
                float dotVR = dot(refVec, i.viewDir);
                // 0以下使用しないようにする
                dotVR = max(0, dotVR);
                dotVR = pow(dotVR, _Reflecition);
                float3 specular = _LightColor0 * _Specular;
                // 内積の補間間として塗り分け
                float4 finalColor = lerp(_MainColor, float4(specular, 1), dotVR);
                return finalColor;
            }
            ENDCG
        }
    }
}
