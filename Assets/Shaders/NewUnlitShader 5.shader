Shader "Unlit/NewUnlitShader 5"
{
    Properties
    {
        _MainTex("Base(RGB)", 2D ) = "white" {}
        _NormalMap("NormalMap",2D) = "bump" {}
        _Shininess("Shininess", Range(0.0, 1.0)) = 0.078125
    }
    SubShader
    {
        Tags{ "Queue" = "Geometry" "RenderType"="Opaque"}
        

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float4 _LightColor0;
            sampler2D _MainTex;
            sampler2D _NormalMap;
            half _Shininess;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                half3 lightDir : TEXCOORD1;
                half3 viewDir : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = v.vertex.xy;
                // 接空間変換用の行列を作成できる。
                TANGENT_SPACE_ROTATION;
                // ライトのオブジェクト空間で方向ベクトルを取得後、接空間に変換。
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 光方向ベクトルを正規化
                i.lightDir = normalize(i.lightDir);
                // 視線ベクトルを正規化
                i.viewDir = normalize(i.viewDir);
                // 
                half3 halfDir = normalize(i.lightDir + i.viewDir);
                half4 tex = tex2D(_MainTex, i.uv);
                // 法線を-1~1にする
                half3 normal = UnpackNormal(tex2D(_NormalMap,i.uv));
                // 拡散反射(法線と光の方向の内積を求めて,0以上に丸める）
                half4 diff = saturate(dot(normal, i.lightDir)) * _LightColor0;
                // 
                half3 spec = pow(max(0, dot(normal, halfDir)), _Shininess * 128.0) * _LightColor0 * tex.rgb;
                fixed4 color;
                color.rgb = tex.rgb * diff + spec;
                return color;
            }
            ENDCG
            // https://blog.applibot.co.jp/2018/03/14/tutorial-for-unity-3d-9/
        }
    }
}
