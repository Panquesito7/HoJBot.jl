module Storage

using Discord
using Discord: Snowflake
using ..PluginBase
export AbstractStoragePlugin, set_default!

abstract type AbstractStoragePlugin <: AbstractPlugin end

const _default_backend=Dict{AbstractPlugin, AbstractStoragePlugin}()
const _FALLBACK_END=Ref{Union{AbstractStoragePlugin, Nothing}}(nothing)

PluginBase.isenabled(guid::Snowflake, ::AbstractStoragePlugin) = true

PluginBase.identifier(p::AbstractStoragePlugin) = string(typeof(p))

PluginBase.get_storage(m::Message, args...) = get_storage(m.guild_id, args...)

PluginBase.get_storage(guild_id::Snowflake, p::AbstractPlugin) = get_storage(guild_id, p, get!(_default_backend, p, _FALLBACK_END[]))

function PluginBase.get_storage(guild_id::Snowflake, p::AbstractPlugin, storage)
    @warn "Storage plugin $storage for $p not found, defaulting..."
    default = get(_default_backend, p, _FALLBACK_END[])
    if storage == default
        @error "default backend is not availabled"
    end
    return get_storage(guild_id, p, default)
end

function set_default!(p::AbstractPlugin, storage::AbstractStoragePlugin)
    _default_backend[p] = storage
end

function set_default!(storage::AbstractStoragePlugin)
    _FALLBACK_END[] = storage
end

end