Shader "Unlit/NewUnlitShader 2"
{
  Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo", 2D) = "white" {}
        _Destruction("Destruction Factor", Range(0.0, 1.0)) = 0.0
        _ScaleFactor("Scale Factor", Range(0.0, 1.0)) = 1.0
        _RotationFactor("Rotation Factor", Range(0.0, 1.0)) = 1.0
        _PositionFactor("Position Factor", Range(0.0, 1.0)) = 0.2
        _AlphaFactor("Alpha Factor", Range(0.0, 1.0)) = 1.0
    }

    SubShader
    {
        Tags{ "Queue"="Transparent" "RenderType"= "Transparent"}
        // アルファブレンディング 
        Blend SrcAlpha OneMinusSrcAlpha
        // かリングをオフにする
        Cull Off

        CGINCLUDE
	    #include "UnityCG.cginc"

        fixed _Destruction, _ScaleFactor, _RotationFactor, _PositionFactor, _AlphaFactor;

        // https://forum.unity.com/threads/am-i-over-complicating-this-random-function.454887/#post-2949326
        float rand(float3 co)
        {
            return frac(sin(dot(co.xyz, float3(12.9898, 78.233, 53.539))) * 43758.5453);
        }

        //回転行列
        fixed3 rotate(fixed3 p, fixed3 rotation)
        {
            //rotationがゼロ行列だと、Geometry shaderが表示されないので注意
            fixed3 a = normalize(rotation);
            float angle = length(rotation);
            //rotationがゼロ行列のときの対応
            if (abs(angle) < 0.001) return p;
            fixed s = sin(angle);
            fixed c = cos(angle);
            fixed r = 1.0 - c;
            fixed3x3 m = fixed3x3(
                a.x * a.x * r + c,
                a.y * a.x * r + a.z * s,
                a.z * a.x * r - a.y * s,
                a.x * a.y * r - a.z * s,
                a.y * a.y * r + c,
                a.z * a.y * r + a.x * s,
                a.x * a.z * r + a.y * s,
                a.y * a.z * r - a.x * s,
                a.z * a.z * r + c
            );

            return mul(m, p);
        }

        struct v2g
        {
            float4 pos : POSITION;
            float3 vertex : TEXCOORD1;
            float2 uv : TEXCOORD0;
        };

        struct g2f
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
            float light : TEXCOORD1;
        };

        v2g vert(appdata_full v)
        {
            v2g o;
            o.vertex = v.vertex;//ローカル座標
            o.pos = UnityObjectToClipPos(v.vertex);
            return o;
        }
// 頂点を三つに設定しつつ三角形プリミティブ型を受け取りそのままの形としてアウトプットする
        [maxvertexcount(3)]
        void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream)
        {
            g2f o;
// 頂点の中心
            float3 center = (IN[0].vertex + IN[1].vertex + IN[2].vertex) / 3;
            //　ランダム関数
            fixed3 r3 = rand(center);

            // 外積つかって、法線ベクトルの計算 ベクトルA ,ベクトルB
            float3 vecA = IN[1].vertex - IN[0].vertex;
            float3 vecB = IN[2].vertex - IN[0].vertex;
            // 外積croosで出してnormalizeする(0~1）
            float3 normal = normalize(cross(vecA, vecB));

            // 光の方向は光のxyz座標を正規化することで取ってこれる 
            float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
            // dotで光の距離と法線の内積をだして0とおおきいかどうかを調べる。
            // 拡散反射とは光が物体に当たると、光の一部が表面で反射し、残りは屈折しながら物体の中に入ります。
            // maxで負の値になったものを全て0にすることで明るさを計算できる。
            o.light = max(0., dot(normal, lightDir));

            [unroll]
            for (int i = 0; i < 3; i++)
            {
                v2g v = IN[i];
// インスタンスIDをもとに位置やスケールを反映。
                //　インスタンスIDがシェーダー関数にアクセスできる。頂点シェーダーの最初に使用される必要があるが
                UNITY_SETUP_INSTANCE_ID(v);
                // 出力構造体（ここでいうv2f）にレンダーリングするメッシュの頂点インデックスを渡すためのマクロ関数
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                // centerを起点に三角メッシュの大きさが変化
                v.vertex.xyz = center + (v.vertex.xyz - center) * (1.0 - _Destruction * _ScaleFactor);

                // centerを起点に、回転行列をしたfixed3を中心座標に加算して
                v.vertex.xyz = center + rotate(v.vertex.xyz - center, r3 * _Destruction * _RotationFactor);

                // 法線方向に弾け飛ぶ xyz座標にそれぞれ法線を起点に　他はスケラーとして乗算する
                v.vertex.xyz += normal * _Destruction * _PositionFactor * r3;
// モデル座標→ワールド座標→ビュー座標→クリップ座標）
                o.pos = UnityObjectToClipPos(v.vertex);
                // 三角形プリミティブの頂点座標はそのまま
                o.uv = v.uv;
                triStream.Append(o);
            }
// 三回やったらrestartする
            triStream.RestartStrip();
        }


        ENDCG

        //ForwardBaseでgeometryを描画
        Pass
        {
            // ForwardBaseとはフォワードレンダリングで最初に実行されるPass
            Tags {"LightMode" = "ForwardBase"}
            CGPROGRAM
            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            float4 _Color;
            sampler2D _MainTex;

            half4 frag(g2f i) : COLOR
            {
                float4 col = tex2D(_MainTex, i.uv);
                //フェードアウト
                col.a *= 1.0 - _Destruction * _AlphaFactor;
                col.rgb *= i.light;
                return col;
            }
            ENDCG
        }

        //ShadowCasterで影だし
        Pass
        {
            // LightModeー>Shadercaster Shadow Casterのライフサイクル時にレンダリングするように支持する。シャドウマップ、深度テクスチャに対象の深度を描画する。
            Tags {"LightMode" = "ShadowCaster"}
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            half4 frag(g2f i) : SV_Target
            {
                // フラグメントシェーダーで実行されて(length(i.vec) + unity_LightShadowBias.x) * _LightPositionRange.wを返す。
                // これは何かという(光源からの距離 + バイアス？） * * 光の、、（これで正規化している）正直あんまりこれで影がFragmentに還元される理由が若rん。。
                SHADOW_CASTER_FRAGMENT(i);
            }
            ENDCG
        }
    }
    Fallback "Diffuse" 
}
